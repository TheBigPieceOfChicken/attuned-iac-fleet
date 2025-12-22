# Phase B: Jamf Connect OIDC Implementation
# Terraform resource definitions for NFR tenant

#=====================================================
# Configuration Profile: 008-IDM-JamfConnect-Login-ALL
#=====================================================
resource "jamfpro_macos_configuration_profile" "jamfconnect_login" {
  name        = "008-IDM-JamfConnect-Login-ALL"
  description = "Modern Google Workspace OIDC authentication via Jamf Connect 3.6+ - No LDAP, pure OIDC with password sync"
  category_id = "2"  # 02-Identity
  level       = "Computer"
  
  # Payload will be managed via import
  # Dependencies: var.google_oauth_client_id, var.google_oauth_client_secret
}

#=====================================================
# Policy: Patch Jamf Connect Latest
#=====================================================
resource "jamfpro_policy" "patch_jamfconnect" {
  name              = "Patch Jamf Connect Latest"
  enabled           = true
  trigger_checkin   = false
  trigger_enrollment= false
  trigger_login     = false
  trigger_logout    = false
  trigger_network_state_change = false
  trigger_startup   = false
  frequency         = "Once every month"
  
  category {
    name = "Maintenance"
  }
  
  # Scope: All computers (exclude Enrolled Today)
  scope {
    all_computers = true
  }
}

#=====================================================
# Policy: 00__Start Jamf Connect Notify
#=====================================================
resource "jamfpro_policy" "start_jc_notify" {
  name              = "00__Start Jamf Connect Notify"
  enabled           = true
  trigger_checkin   = false
  trigger_enrollment= false
  trigger_login     = false
  trigger_logout    = false
  trigger_network_state_change = false
  trigger_startup   = false
  trigger_other     = "start-jcnotify"
  
  category {
    name = "Provisioning"
  }
  
  # Script configuration will be managed via import
}
