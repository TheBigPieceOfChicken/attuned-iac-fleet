output "login_profile_id" {
  description = "ID of the Jamf Connect Login configuration profile"
  value       = jamfpro_macos_configuration_profile_plist.jamf_connect_login.id
}

output "privilege_profile_id" {
  description = "ID of the Jamf Connect Privilege Elevation profile"
  value       = var.enable_privilege_elevation ? jamfpro_macos_configuration_profile_plist.jamf_connect_privilege[0].id : null
}
