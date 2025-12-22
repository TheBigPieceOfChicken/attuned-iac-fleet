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
  payload_validate    = false
  
  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Policy: Patch Jamf Connect Latest (ID: 49)
resource "jamfpro_policy" "patch_jamf_connect" {
  name                          = "Patch Jamf Connect Latest"
  enabled                       = true
  trigger_checkin               = true
  trigger_enrollment_complete   = false
  trigger_login                 = false
  trigger_network_state_changed = false
  trigger_startup               = false
  trigger_other                 = ""
  frequency                     = "Once every month"
  retry_event                   = "none"
  retry_attempts                = -1
  notify_on_each_failed_retry   = false
  target_drive                  = "/"
  offline                       = false
  category_id                   = -1 # Will be updated after category import
  site_id                       = -1

  payloads {
    packages {
      distribution_point = "default"
      package {
        id                          = -1 # Reference to Jamf Connect package
        action                      = "Install"
        fill_user_template          = false
        fill_existing_user_template = false
      }
    }
  }

  scope {
    all_computers = true
    all_jss_users = false
  }

  limitations {
    network_segment_ids = []
  }

  exclusions {
    computer_group_ids = [] # Exclude "Enrolled Today" group
  }
}

# Policy: Start Jamf Connect Notify (ID: 33)
resource "jamfpro_policy" "start_jamf_connect_notify" {
  name                          = "00__Start Jamf Connect Notify"
  enabled                       = true
  trigger_checkin               = false
  trigger_enrollment_complete   = false
  trigger_login                 = false
  trigger_network_state_changed = false
  trigger_startup               = false
  trigger_other                 = "start-jcnotify" # Custom event
  frequency                     = "Ongoing"
  retry_event                   = "none"
  retry_attempts                = -1
  notify_on_each_failed_retry   = false
  target_drive                  = "/"
  offline                       = false
  category_id                   = -1 # Provisioning category
  site_id                       = -1

  payloads {
    scripts {
      id         = -1 # Reference to Jamf Connect Notify script
      priority   = "After"
      parameter4 = ""
      parameter5 = ""
      parameter6 = ""
      parameter7 = ""
      parameter8 = ""
      parameter9 = ""
      parameter10 = ""
      parameter11 = ""
    }
  }

  scope {
    all_computers = true
    all_jss_users = false
  }
}
