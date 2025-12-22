#!/usr/bin/env python3
"""
Jamf Pro Configuration Profile Export Script

This script fetches all macOS configuration profiles from Jamf Pro and generates:
1. Individual plist files in payloads/ directory
2. Terraform resource definitions for main.tf

Usage:
    python3 export-jamf-profiles.py

Environment Variables Required:
    JAMF_URL - Jamf Pro instance URL (e.g., https://attunednfr.jamfcloud.com)
    JAMF_CLIENT_ID - Jamf Pro API client ID
    JAMF_CLIENT_SECRET - Jamf Pro API client secret
"""

import os
import sys
import json
import requests
import xml.etree.ElementTree as ET
from pathlib import Path
import re

# Configuration
JAMF_URL = os.getenv('JAMF_URL', 'https://attunednfr.jamfcloud.com')
JAMF_CLIENT_ID = os.getenv('JAMF_CLIENT_ID')
JAMF_CLIENT_SECRET = os.getenv('JAMF_CLIENT_SECRET')

if not all([JAMF_CLIENT_ID, JAMF_CLIENT_SECRET]):
    print("Error: JAMF_CLIENT_ID and JAMF_CLIENT_SECRET environment variables required")
    sys.exit(1)

def get_auth_token():
    """Get Jamf Pro API bearer token"""
    url = f"{JAMF_URL}/api/v1/auth/token"
    response = requests.post(
        url,
        auth=(JAMF_CLIENT_ID, JAMF_CLIENT_SECRET),
        headers={'Accept': 'application/json'}
    )
    response.raise_for_status()
    return response.json()['token']

def get_all_profiles(token):
    """Fetch all configuration profiles from Jamf Pro"""
    url = f"{JAMF_URL}/JSSResource/osxconfigurationprofiles"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/xml'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.text

def get_profile_details(token, profile_id):
    """Fetch detailed information for a specific profile"""
    url = f"{JAMF_URL}/JSSResource/osxconfigurationprofiles/id/{profile_id}"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/xml'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.text

def sanitize_resource_name(name):
    """Convert profile name to Terraform resource identifier"""
    # Remove number prefix and convert to lowercase
    name = re.sub(r'^\d+-', '', name)
    # Replace hyphens and spaces with underscores
    name = re.sub(r'[-\s]+', '_', name.lower())
    # Remove any non-alphanumeric characters except underscores
    name = re.sub(r'[^a-z0-9_]', '', name)
    return name

def parse_scope(scope_elem):
    """Parse scope information from XML"""
    all_computers = scope_elem.find('.//all_computers')
    all_jss_users = scope_elem.find('.//all_jss_users')
    
    return {
        'all_computers': all_computers.text.lower() == 'true' if all_computers is not None else False,
        'all_jss_users': all_jss_users.text.lower() == 'true' if all_jss_users is not None else False
    }

def generate_terraform_resource(profile_xml, payloads_dir):
    """Generate Terraform resource definition from profile XML"""
    root = ET.fromstring(profile_xml)
    
    # Extract profile information
    profile_id = root.find('general/id').text
    name = root.find('general/name').text
    description = root.find('general/description').text or ""
    category = root.find('general/category/name').text if root.find('general/category/name') is not None else ""
    distribution_method = root.find('general/distribution_method').text
    level = root.find('general/level').text
    redeploy_on_update = root.find('general/redeploy_on_update').text
    
    # Get scope
    scope_elem = root.find('scope')
    scope = parse_scope(scope_elem)
    
    # Get payloads (plist content)
    payloads = root.find('general/payloads').text if root.find('general/payloads') is not None else None
    
    if not payloads:
        print(f"Warning: Profile {name} has no payloads, skipping")
        return None
    
    # Save plist file
    plist_filename = f"{name}.plist"
    plist_path = payloads_dir / plist_filename
    with open(plist_path, 'w') as f:
        f.write(payloads)
    
    # Generate Terraform resource
    resource_name = sanitize_resource_name(name)
    category_id = "-1"  # Default category
    
    terraform_resource = f'''# {name}
resource "jamfpro_macos_configuration_profile_plist" "{resource_name}" {{
  name                 = "{name}"
  description          = "{description}"
  category_id          = "{category_id}"
  distribution_method  = "{distribution_method}"
  level                = "{level}"
  payloads             = file("${{path.root}}/payloads/{plist_filename}")
  redeploy_on_update   = "{redeploy_on_update}"
  payload_validate     = false  # Bypass strict provider validation
  
  scope {{
    all_computers = {str(scope['all_computers']).lower()}
    all_jss_users = {str(scope['all_jss_users']).lower()}
  }}
}}

'''
    
    return terraform_resource

def main():
    """Main execution"""
    print("Starting Jamf Pro Configuration Profile Export...")
    print(f"Jamf URL: {JAMF_URL}")
    
    # Create payloads directory
    payloads_dir = Path('payloads')
    payloads_dir.mkdir(exist_ok=True)
    
    # Authenticate
    print("Authenticating with Jamf Pro API...")
    token = get_auth_token()
    print("✓ Authentication successful")
    
    # Fetch all profiles
    print("Fetching configuration profiles list...")
    profiles_xml = get_all_profiles(token)
    root = ET.fromstring(profiles_xml)
    profile_elements = root.findall('.//os_x_configuration_profile')
    print(f"✓ Found {len(profile_elements)} configuration profiles")
    
    # Process each profile
    terraform_resources = []
    skipped = []
    
    for idx, profile_elem in enumerate(profile_elements, 1):
        profile_id = profile_elem.find('id').text
        profile_name = profile_elem.find('name').text
        
        print(f"\n[{idx}/{len(profile_elements)}] Processing: {profile_name} (ID: {profile_id})")
        
        try:
            # Get detailed profile info
            profile_xml = get_profile_details(token, profile_id)
            
            # Generate Terraform resource
            terraform_resource = generate_terraform_resource(profile_xml, payloads_dir)
            
            if terraform_resource:
                terraform_resources.append(terraform_resource)
                print(f"  ✓ Exported plist and generated Terraform resource")
            else:
                skipped.append(profile_name)
                
        except Exception as e:
            print(f"  ✗ Error processing profile: {e}")
            skipped.append(profile_name)
            continue
    
    # Write Terraform configuration to file
    print("\n" + "="*60)
    print("Writing Terraform configuration to main.tf.generated...")
    with open('main.tf.generated', 'w') as f:
        f.write("# Generated Terraform Configuration for Jamf Pro\n")
        f.write("# This file was automatically generated from Jamf Pro API\n\n")
        f.write(''.join(terraform_resources))
    
    print(f"✓ Wrote {len(terraform_resources)} resources to main.tf.generated")
    
    if skipped:
        print(f"\n⚠ Skipped {len(skipped)} profiles:")
        for name in skipped:
            print(f"  - {name}")
    
    print("\n" + "="*60)
    print("Export complete!")
    print(f"Next steps:")
    print(f"1. Review main.tf.generated")
    print(f"2. Merge resources into main.tf (or organize into modules)")
    print(f"3. Test with: terraform plan")
    print(f"4. Deploy with: terraform apply")

if __name__ == '__main__':
    main()
