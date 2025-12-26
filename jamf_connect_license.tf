resource "jamfpro_macos_configuration_profile_plist" "jamf_connect_license" {
  name                = "Jamf Connect License"
  description         = "Jamf Connect license for ${var.client.organization}"
  level               = "System"
  distribution_method = "Install Automatically"
  redeploy_on_update  = "Newly Assigned"
  payload_validate    = false

  payloads = templatefile("${path.module}/payloads/010-IDM-JamfConnect-License.plist.tpl", {
    license_key     = var.client.jamf_connect.license_key
    name            = var.client.name
    email           = var.client.jamf_connect.email
    date_issued     = var.client.jamf_connect.date_issued
    expiration_date = var.client.jamf_connect.expiration_date
    signature       = var.client.jamf_connect.signature
    edition         = var.client.jamf_connect.edition
    major_version   = var.client.jamf_connect.major_version
    num_clients     = var.client.jamf_connect.num_clients
    organization    = var.client.organization
  })

  scope {
    all_computers = true
  }
}
