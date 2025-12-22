# Jamf Pro Terraform Configuration
# This file contains resource definitions for the NFR tenant
# Resources will be imported and managed via Terraform

# Configuration profiles, policies, and other resources will be added here

# Configuration Profile: 008-IDM-JamfConnect-Login-ALL (ID: 120)
resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_login" {
  name                = "008-IDM-JamfConnect-Login-ALL"
  description         = "Modern Google Workspace OIDC authentication via Jamf Connect 3.6+ - No LDAP, pure OIDC with password sync"
  category_id         = "-1" # Will be updated after category import
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/008-IDM-JamfConnect-Login-ALL.plist")
  redeploy_on_update  = "Newly Assigned"
  
  scope {
    all_computers = true
    all_jss_users = false
  }
}
