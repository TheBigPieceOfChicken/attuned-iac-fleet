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

# ==============================================================================
# Script Resource ~ Installomator (Application Deployment)
# ==============================================================================

# Import existing script into Terraform state
import {
  to = jamfpro_script.installomator
  id = "14"
}

resource "jamfpro_script" "installomator" {
  name        = "Installomator"
  category_id = "1"
  priority    = "AFTER"
  script_contents = "# Managed by import - content pulled from existing Jamf Pro script ID 14"
  
  lifecycle {
    ignore_changes = [script_contents]
  }
}

# Note: Installomator is used by 13+ application deployment policies
# Script provides automated application installation and updates

# ===========================================================================
# Policy Resource ~ Patch Jamf Connect Latest
# ===========================================================================

resource "jamfpro_policy" "patch_jamf_connect" {
  name                       = "Patch Jamf Connect Latest"
  enabled                    = true
  category_id                = "14"
  trigger_checkin                     = true
  trigger_enrollment_complete  = false
  trigger_login                = false
  trigger_network_state_changed = false
  trigger_startup              = false
  trigger_other                = "none"
  frequency                    = "Once per computer"
  retry_event                  = "none"
  retry_attempts               = -1
  notify_on_each_failed_retry  = false
  target_drive                 = "/"
  offline                      = false

  # Package configuration - references existing package ID 24
 payloads {
  packages {
    distribution_point = "default"
    package {
      id = "24"
      action = "Install"
    }
  }
}  # Close payloads

scope {  # Scope should be at policy level
  all_jss_users = false
  all_computers = true

# ================================================================================
# PPPC Configuration Profiles ~ Privacy Preferences Policy Control
# ================================================================================

# Import existing PPPC Aftermath profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_aftermath
  id = "109"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_aftermath" {
  name                = "PPPC - Aftermath"
  description         = "Privacy Preferences Policy Control for Aftermath forensics tool"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-Aftermath.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Google Chrome profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_google_chrome
  id = "88"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_google_chrome" {
  name                = "PPPC Google Chrome"
  description         = "Privacy Preferences Policy Control for Google Chrome"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-GoogleChrome.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Google Drive profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_google_drive
  id = "87"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_google_drive" {
  name                = "PPPC Google Drive"
  description         = "Privacy Preferences Policy Control for Google Drive"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-GoogleDrive.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Keeper profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_keeper
  id = "89"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_keeper" {
  name                = "PPPC Keeper"
  description         = "Privacy Preferences Policy Control for Keeper Password Manager"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-Keeper.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Level RMM profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_level_rmm
  id = "92"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_level_rmm" {
  name                = "PPPC Level RMM"
  description         = "Privacy Preferences Policy Control for Level RMM agent"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-LevelRMM.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Slack profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_slack
  id = "90"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_slack" {
  name                = "PPPC Slack"
  description         = "Privacy Preferences Policy Control for Slack"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-Slack.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Import existing PPPC Zoom profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_zoom
  id = "91"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_zoom" {
  name                = "PPPC Zoom"
  description         = "Privacy Preferences Policy Control for Zoom"
  category_id         = "1"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/PPPC-Zoom.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}

# Note: PPPC profiles manage system-level privacy permissions for applications
# Each profile grants specific TCC (Transparency, Consent, and Control) permissions
# Payloads will need to be exported from existing Jamf Pro profiles
}
}  # Close policy resource
