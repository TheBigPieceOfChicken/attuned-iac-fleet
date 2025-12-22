#!/usr/bin/env python3
"""
Jamf Pro Configuration Profile List Script (DRY RUN)

This script simply lists all configuration profiles from Jamf Pro without downloading anything.
Use this to assess what profiles exist before attempting bulk export.

Usage:
    python3 list-jamf-profiles.py

Environment Variables Required:
    JAMF_URL - Jamf Pro instance URL (e.g., https://attunednfr.jamfcloud.com)
    JAMF_CLIENT_ID - Jamf Pro API client ID
    JAMF_CLIENT_SECRET - Jamf Pro API client secret
"""

import os
import sys
import requests
import xml.etree.ElementTree as ET
from collections import defaultdict

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
    try:
        response = requests.post(
            url,
            auth=(JAMF_CLIENT_ID, JAMF_CLIENT_SECRET),
            headers={'Accept': 'application/json'},
            timeout=10
        )
        response.raise_for_status()
        return response.json()['token']
    except requests.exceptions.RequestException as e:
        print(f"Error authenticating: {e}")
        sys.exit(1)

def get_all_profiles(token):
    """Fetch list of all configuration profiles from Jamf Pro"""
    url = f"{JAMF_URL}/JSSResource/osxconfigurationprofiles"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/xml'
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error fetching profiles: {e}")
        sys.exit(1)

def categorize_profiles(profiles):
    """Categorize profiles by naming prefix"""
    categories = defaultdict(list)
    for profile in profiles:
        name = profile['name']
        # Extract prefix (e.g., "001-SEC", "010-IDM")
        parts = name.split('-', 2)
        if len(parts) >= 2:
            category = parts[1]  # SEC, IDM, EPP, etc.
            categories[category].append(profile)
        else:
            categories['OTHER'].append(profile)
    return categories

def main():
    """Main execution"""
    print("="*70)
    print("JAMF PRO CONFIGURATION PROFILE INVENTORY - DRY RUN")
    print("="*70)
    print(f"\nJamf URL: {JAMF_URL}")
    print("\nThis script will list all profiles without making any changes.\n")
    
    # Authenticate
    print("[1/2] Authenticating with Jamf Pro API...")
    try:
        token = get_auth_token()
        print("      ✓ Authentication successful\n")
    except Exception as e:
        print(f"      ✗ Authentication failed: {e}")
        sys.exit(1)
    
    # Fetch profiles list
    print("[2/2] Fetching configuration profiles list...")
    try:
        profiles_xml = get_all_profiles(token)
        root = ET.fromstring(profiles_xml)
        profile_elements = root.findall('.//os_x_configuration_profile')
        print(f"      ✓ Found {len(profile_elements)} configuration profiles\n")
    except Exception as e:
        print(f"      ✗ Failed to fetch profiles: {e}")
        sys.exit(1)
    
    # Parse profile data
    profiles = []
    for elem in profile_elements:
        profile_id = elem.find('id').text
        profile_name = elem.find('name').text
        profiles.append({
            'id': profile_id,
            'name': profile_name
        })
    
    # Categorize profiles
    categorized = categorize_profiles(profiles)
    
    # Display results
    print("="*70)
    print("PROFILE INVENTORY BY CATEGORY")
    print("="*70)
    
    total = 0
    for category in sorted(categorized.keys()):
        profile_list = categorized[category]
        print(f"\n{category} Category: {len(profile_list)} profiles")
        print("-" * 70)
        for profile in sorted(profile_list, key=lambda x: x['name']):
            print(f"  [ID: {profile['id']:>3}]  {profile['name']}")
        total += len(profile_list)
    
    # Summary
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"Total profiles found:     {total}")
    print(f"Number of categories:     {len(categorized)}")
    print(f"")
    print("Profile categories breakdown:")
    for category in sorted(categorized.keys()):
        count = len(categorized[category])
        percentage = (count / total * 100) if total > 0 else 0
        print(f"  {category:15s}: {count:3d} profiles ({percentage:5.1f}%)")
    
    print("\n" + "="*70)
    print("NEXT STEPS")
    print("="*70)
    print("1. Review the profile list above")
    print("2. Identify critical profiles to migrate first")
    print("3. Run export-jamf-profiles.py to begin bulk export")
    print("4. Or manually add profiles one category at a time")
    print("\n")

if __name__ == '__main__':
    main()
