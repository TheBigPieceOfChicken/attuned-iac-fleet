resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_license" {
  name                = "Jamf Connect License"
  description         = "Jamf Connect license for ${var.client.organization}"
  level               = "System"
  distribution_method = "Install Automatically"
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  payloads = templatefile("${path.module}/payloads/010-IDM-JamfConnect-License.plist.tpl", {
    license_file_base64 = var.jamf_connect_license_base64
    organization        = var.client.organization
  })

  scope {
    all_computers = true
  }
}
