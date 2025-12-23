# Jamf Pro Terraform Configuration
# This file contains resource definitions for the NFR tenant
# Resources will be imported and managed via Terraform

# Configuration profiles, policies, and other resources will be added here

# Configuration Profile: 008-IDM-JamfConnect-Login-ALL (ID: 120)
resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_login" {
  name                  = "008-IDM-JamfConnect-Login-ALL"
  description           = "Modern Google Workspace OIDC authentication via Jamf Connect 3.6+ - No DS"
  category_id           = "-1" # Will be updated after category import
  distribution_method   = "Install Automatically"
  level                 = "System"
  payloads              = file("${path.root}/payloads/008-IDM-JamfConnect-Login-ALL.plist")
  redeploy_on_update    = "Newly Assigned"
  payload_validate      = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Note: Policies will be added after scripts and packages are created/imported
# TODO: Add jamfpro_policy resources after dependencies are resolved

# ==============================================================================
# Script Resource - 00__Start JC Notify (OIDC Compatible)
# ==============================================================================

# Import existing script into Terraform state
import {
  to = jamfpro_script.start_jc_notify
  id = "15"
}
resource "jamfpro_script" "start_jc_notify" {
  name             = "00__Start JC Notify"
  priority         = "BEFORE"
  script_contents  = file("${path.root}/scripts/00__Start-JC-Notify.sh")

  # Note: Script is OIDC compatible - no changes needed
  # Uses Jamf Connect Notify mode for provisioning UI
  # Authentication handled by configuration profile (ID: 120)
}

# ========================================================================
# Package Resource - Jamf Connect 3.5.0
# ========================================================================

# Import existing package into Terraform state
import {
  to = jamfpro_package.jamf_connect_latest
  id = "24"
}

resource "jamfpro_package" "jamf_connect_latest" {
  name               = "1-JamfConnect-Latest.pkg"
  category_id        = "11"  # Applications category
  filename           = "1-JamfConnect-Latest.pkg"
  # Note: This will be replaced with modern OIDC-compatible package in Phase C
}

# ==============================================================================
# Policy Resource - Patch Jamf Connect Latest
# ==============================================================================
resource "jamfpro_policy" "patch_jamf_connect" {
  name                          = "Patch Jamf Connect Latest"
  enabled                       = true
  category_id          = "14" 
trigger_checkin               = true
  trigger_enrollment_complete   = false
  trigger_login                 = false
  trigger_network_state_changed = false
  trigger_startup               = false
  trigger_other                 = "none"
  frequency                     = "Once per computer"
  retry_event                   = "none"
  retry_attempts                = -1
  notify_on_each_failed_retry   = false
  target_drive                  = "/"
  offline                       = false

  # Package configuration - references existing package ID 24
  payloads {
    packages {
      distribution_point = "default"
      package {
        id     = 24  # 1-JamfConnect-Latest.pkg (legacy stub)
        action = "Install"
      }
    }
  }

  scope {
    all_computers = true
    all_jss_users = false
  }

  # TODO: Once modern Jamf Connect 3.5.0 package is uploaded:
  # 1. Upload new package to Jamf Pro
  # 2. Note the new package ID
  # 3. Update the package ID above
}

# ==============================================================================
# Import Blocks - Import existing Jamf Pro resources into Terraform state
# ==============================================================================

# Import existing policy (ID: 49)
import {
  to = jamfpro_policy.patch_jamf_connect
  id = "49"
}

