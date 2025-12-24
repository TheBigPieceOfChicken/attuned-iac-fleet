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

# Configuration Profile: 009-IDM-JamfConnect-PrivilegeElevation-ALL (ID: 121)
resource "jamfpro_macos_configuration_profile_plist" "jamfconnect_privilege_elevation" {
  name                  = "009-IDM-JamfConnect-PrivilegeElevation-ALL"
  description           = "Enables temporary privilege elevation via Jamf Connect menu bar - 30 min duration with OIDC authentication"
  category_id           = "-1"  # Will be updated after category import
  distribution_method   = "Install Automatically"
  level                 = "System"
  payloads              = file("${path.root}/payloads/009-IDM-JamfConnect-PrivilegeElevation-ALL.plist")
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
  name                          = "Patch Jamf Connect Latest"
  enabled                       = true
  category_id                   = "14"
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
        id     = "24"
        action = "Install"
      }
    }
  }

  scope {
    all_jss_users = false
    all_computers = true
  }
}

# ================================================================================
# 107 ~ Privacy Preferences Policy Control
# ================================================================================

# Import existing PPPC Aftermath profile
import {
  to = jamfpro_macos_configuration_profile_plist.pppc_aftermath
  id = "109"
}

resource "jamfpro_macos_configuration_profile_plist" "pppc_aftermath" {
  name                = "PPPC - Aftermath"
  description         = "Privacy Preferences Policy Control for Aftermath forensics tool"
  category_id         = "17"
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
  category_id         = "17"
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
  category_id         = "17"
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
  category_id         = "17"
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
  category_id         = "17"
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
  category_id         = "17"
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
  category_id         = "17"
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


# ========================================================================
# Security Profile ~ 002-SEC-Firewall-ALL (ID: 113)
# ========================================================================

# Import existing Security Firewall profile
# ========================================================================

import {
  to = jamfpro_macos_configuration_profile_plist.sec_firewall
  id = "113"
}

resource "jamfpro_macos_configuration_profile_plist" "sec_firewall" {
  name                = "002-SEC-Firewall-ALL"
  description         = "macOS Application Firewall enabled with block all incoming connections"
  category_id         = "22"
  distribution_method = "Install Automatically"
  level               = "System"
  payloads            = file("${path.root}/payloads/SEC-Firewall.plist")
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  scope {
    all_computers = true
    all_jss_users = false
  }
}


# ====================================================================================
# Security Scripts ~ Gatekeeper & Password Policy Enforcement
# ====================================================================================

# Script Resource ~ enforce-gatekeeper.sh
resource "jamfpro_script" "enforce_gatekeeper" {
  name            = "enforce-gatekeeper.sh"
  category_id     = "22"  # 01_Security category
  info            = "Enforces Gatekeeper settings - requires App Store and identified developers"
  notes           = "Created via Terraform IaC - Part of security baseline enforcement"
  priority        = "AFTER"
  os_requirements = "10.14.x"
  script_contents = file("${path.root}/scripts/enforce-gatekeeper.sh")
}

# Script Resource ~ enforce-password-policy.sh  
resource "jamfpro_script" "enforce_password" {
  name            = "enforce-password-policy.sh"
  category_id     = "22"  # 01_Security category
  info            = "Enforces password complexity requirements via pwpolicy"
  notes           = "Created via Terraform IaC - Part of security baseline enforcement"
  priority        = "AFTER"
  os_requirements = "10.14.x"
  script_contents = file("${path.root}/scripts/enforce-password-policy.sh")
}

# ====================================================================================
# Security Policies ~ Script Execution via Recurring Check-in
# ====================================================================================

# Policy ~ SEC - Enforce Gatekeeper
resource "jamfpro_policy" "sec_enforce_gatekeeper" {
  name                          = "SEC - Enforce Gatekeeper"
  enabled                       = true
  trigger_checkin               = true
  trigger_enrollment_complete   = false
  trigger_login                 = false
  trigger_network_state_changed = false
  trigger_startup               = false
  frequency                     = "Once per computer"
  category_id                   = 22  # 01_Security
  
  scope {
    all_computers = true
    all_jss_users = false
  }
  
  payloads {
    scripts {
      id       = jamfpro_script.enforce_gatekeeper.id
      priority = "After"
    }
    
    maintenance {
      recon = true
    }
  }
}

# Policy ~ SEC - Enforce Password Policy
resource "jamfpro_policy" "sec_enforce_password" {
  name                          = "SEC - Enforce Password Policy"
  enabled                       = true
  trigger_checkin               = true
  trigger_enrollment_complete   = false
  trigger_login                 = false
  trigger_network_state_changed = false
  trigger_startup               = false
  frequency                     = "Once per computer"
  category_id                   = 22  # 01_Security
  
  scope {
    all_computers = true
    all_jss_users = false
  }
  
  payloads {
    scripts {
      id       = jamfpro_script.enforce_password.id
      priority = "After"
    }
    
    maintenance {
      recon = true
    }
  }
}

# lapsadmin Self Service+ Configuration
# ================================================================================

# Self Service+ Branding - Default macOS Branding (ID: 1)
# Note: Self Service branding requires icon_id and banner_image_id (numeric) which must be
# uploaded to Jamf separately. Current branding (ID: 1) exists in Jamf and should be
# imported or managed manually. Image upload is not supported by Terraform provider.

# Self Service+ Settings - Catalog Configuration
resource "jamfpro_self_service_settings" "macos" {
  install_automatically    = true
  install_location         = "/Applications"
  user_login_level         = "Anonymous"
  allow_remember_me        = true
  use_fido2                = false
  auth_type                = "Basic"
  notifications_enabled    = true
  alert_user_approved_mdm  = true
  default_landing_page     = "HOME"
  default_home_category_id = -1
  bookmarks_name           = "Bookmarks"
}

# Note: Individual bookmarks are not yet supported by the jamfpro Terraform provider
# Bookmarks must be managed manually in Jamf Pro UI or via API scripts
# Current bookmarks configured:

# ================================================================================
# User-Initiated Enrollment Settings
# ================================================================================

# User-Initiated Enrollment - Global Settings for Computers
resource "jamfpro_user_initiated_enrollment_settings" "uie_settings" {
  # General Settings
  restrict_reenrollment_to_authorized_users_only  = false
  skip_certificate_installation_during_enrollment = true

  # Computer Enrollment Settings
  user_initiated_enrollment_for_computers {
    enable_user_initiated_enrollment_for_computers = true
    ensure_ssh_is_enabled                          = false
    launch_self_service_when_done                  = false
    account_driven_device_enrollment               = false

    # Managed Local Administrator Account (LAPS)
    managed_local_administrator_account {
      create_managed_local_administrator_account                    = true
      management_account_username                                   = "attunelaps"
      hide_managed_local_administrator_account                      = true
      allow_ssh_access_for_managed_local_administrator_account_only = true
    }
  }

  # Enrollment Messaging - English (required)
  messaging {
    language_code                                   = "en"
    language_name                                   = "English"
    page_title                                      = "Welcome to Attuned IT"
    username_text                                   = "Username"
    password_text                                   = "Password"
    login_button_text                               = "Log In"
    device_ownership_page_text                      = "Select your device type"
    personal_device_button_name                     = "Personal Device"
    institutional_ownership_button_name             = "Company Device"
    personal_device_management_description          = "Your personal device will be managed with minimal restrictions"
    institutional_device_management_description     = "This Mac will be configured with secure access and company applications."
    enroll_device_button_name                       = "Continue"
    eula_personal_devices                           = "By enrolling, you agree to allow management of your personal device"
    eula_institutional_devices                      = "This device is subject to management policies as per company guidelines"
    accept_button_text                              = "Accept"
    site_selection_text                             = "Select your site"
    ca_certificate_installation_text                = "Install CA Certificate"
    ca_certificate_name                             = "Attuned IT Root CA"
    ca_certificate_description                      = "This certificate allows secure communication with company servers"
    ca_certificate_install_button_name              = "Install CA"
    institutional_mdm_profile_installation_text     = "Install Management Profile"
    institutional_mdm_profile_name                  = "Attuned IT MDM Profile"
    institutional_mdm_profile_description           = "This profile allows management of your company device"
    institutional_mdm_profile_pending_text          = "Installing MDM profile..."
    institutional_mdm_profile_install_button_name   = "Install"
    personal_mdm_profile_installation_text          = "Install Personal Device Profile"
    personal_mdm_profile_name                       = "Personal Device Profile"
    personal_mdm_profile_description                = "Limited management profile for personal devices"
    personal_mdm_profile_install_button_name        = "Install Profile"
    user_enrollment_mdm_profile_installation_text   = "Install User Enrollment Profile"
    user_enrollment_mdm_profile_name                = "User Enrollment Profile"
    user_enrollment_mdm_profile_description         = "Profile for user-based enrollment"
    user_enrollment_mdm_profile_install_button_name = "Install"
    quickadd_package_installation_text              = "Install Management Software"
# Computer PreStage Enrollment - Jamf Connect - Google OIDC (ID: 1)    quickadd_package_progress_text                  = "Installing management software..."
    quickadd_package_install_button_name            = "Install Software"
    enrollment_complete_text                        = "Enrollment Complete! Your device is now managed."
    enrollment_failed_text                          = "Enrollment Failed. Please try again."
    quickadd_package_name                     = "Attuned IT MDM Agent"    view_enrollment_status_button_name              = "Check Status"
    view_enrollment_status_text                     = "Check your enrollment status"
    log_out_button_name                             = "Log Out"
  }
}

# ====================================================================================
# Computer PreStage Enrollment - Jamf Connect - Google OIDC (ID: 1)# ====================================================================================
import {
  to = jamfpro_computer_prestage_enrollment.filevault_jamf_connect
  id = "1"
}

resource "jamfpro_computer_prestage_enrollment" "filevault_jamf_connect" {
  Jamf Connect - Google OIDC
  mandatory                             = true    # Make MDM Profile Mandatory: checked
  mdm_removable                         = false   # Allow MDM Profile Removal: unchecked
  support_phone_number                  = ""
  support_email_address                 = "nfrjamf@attuned.it"
  department                            = ""
  default_prestage                      = true    # Automatically assign new devices: checked
  enrollment_site_id                    = "-1"
  keep_existing_site_membership         = false
  keep_existing_location_information    = false   # Use existing location information: unchecked
  require_authentication                = false   # Require Authentication: unchecked
  authentication_prompt                 = ""
  prevent_activation_lock               = true    # Prevent user from enabling Activation Lock: checked
  enable_device_based_activation_lock   = false
  device_enrollment_program_instance_id = "1"     # Attuned-JAMF instance

  language                                 = "en"
  region                                   = "US"
  enrollment_customization_id              = "0"   # None selected
  install_profiles_during_setup            = true
  prestage_installed_profile_ids           = ["128"]]
  custom_package_ids                       = []
  custom_package_distribution_point_id     = "-1"
  enable_recovery_lock                     = false  # Set Recovery Lock Password: unchecked
  recovery_lock_password_type              = "MANUAL"
  rotate_recovery_lock_password            = false
  prestage_minimum_os_target_version_type  = "MINIMUM_OS_LATEST_VERSION"

  # All Setup Assistant items checked = SKIP them (true)
  skip_setup_items {
    biometric                    = true   # Touch ID / Face ID
    terms_of_address             = true   # Terms of Address
    file_vault                   = true   # FileVault
    icloud_diagnostics           = true   # iCloud Diagnostics
    diagnostics                  = true   # App Analytics
    accessibility                = true   # Accessibility
    apple_id                     = true   # Apple ID
    screen_time                  = true   # Screen Time
    siri                         = true   # Siri
    display_tone                 = true   # True Tone Display (Deprecated)
    restore                      = true   # Transfer Information
    appearance                   = true   # Choose your Look
    privacy                      = true   # Privacy
    payment                      = true   # Apple Pay
    registration                 = true   # Registration
    tos                          = true   # Terms and Conditions
    icloud_storage               = true   # All Your Files in iCloud
    location                     = true   # Location Services
    intelligence                 = true   # Intelligence
    enable_lockdown_mode         = true   # Enable Lockdown Mode
    welcome                      = true   # Get Started
    software_update              = true   # Software Update
    wallpaper                    = true   # Wallpaper
    os_showcase                  = true   # OS Showcase
    additional_privacy_settings  = true   # Additional Privacy Settings
  }

  site_id            = "-1"
  auto_advance_setup = true   # Automatically advance through Setup Assistant: checked

  location_information {
    username      = ""
    realname      = ""
    phone         = ""
    email         = ""
    room          = ""
    position      = ""
    department_id = "-1"
    building_id   = "-1"
  }

  purchasing_information {
    leased             = false
    purchased          = true
    apple_care_id      = ""
    po_number          = ""
    vendor             = ""
    purchase_price     = ""
    life_expectancy    = 0
    purchasing_account = ""
    purchasing_contact = ""
    lease_date         = "1970-01-01"
    po_date            = "1970-01-01"
    warranty_date      = "1970-01-01"
  }

  account_settings {
    payload_configured                           = true
    local_admin_account_enabled                  = false
    admin_username                               = ""
    admin_password                               = ""
    hidden_admin_account                         = false
    local_user_managed                           = false
    user_account_type                            = "ADMINISTRATOR"
    prefill_primary_account_info_feature_enabled = false
    prefill_type                                 = "UNKNOWN"
    prefill_account_full_name                    = ""
    prefill_account_user_name                    = ""
    prevent_prefill_info_from_modification       = false
  }
}

