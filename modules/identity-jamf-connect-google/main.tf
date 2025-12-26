terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.30.0"
    }
  }
}

# Jamf Connect Login Configuration Profile
resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_login" {
  name              = var.login_profile_name
  description       = "Jamf Connect Login window configuration for Google OIDC"
  level             = "System"
  category_id       = var.category_id
  distribution_method = "Install Automatically"
  redeploy_on_update  = "Newly Assigned"

  payloads = file("${path.root}/payloads/008-IDM-JamfConnect-Login-ALL.plist")

  scope {
    all_computers = var.scope_all_computers
    
    dynamic "computer_group_ids" {
      for_each = var.scope_smart_group_ids
      content {
        id = computer_group_ids.value
      }
    }
  }
}

# Jamf Connect Privilege Elevation Configuration Profile
resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_privilege" {
  count = var.enable_privilege_elevation ? 1 : 0

  name              = var.privilege_profile_name
  description       = "Jamf Connect Privilege Elevation configuration"
  level             = "System"
  category_id       = var.category_id
  distribution_method = "Install Automatically"
  redeploy_on_update  = "Newly Assigned"

  payloads = file("${path.root}/payloads/009-IDM-JamfConnect-PrivilegeElevation-ALL.plist")

  scope {
    all_computers = var.scope_all_computers
    
    dynamic "computer_group_ids" {
      for_each = var.scope_smart_group_ids
      content {
        id = computer_group_ids.value
      }
    }
  }
}
