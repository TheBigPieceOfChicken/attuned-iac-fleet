# Variables for Jamf Pro Terraform Configuration
# These are set in Scalr workspace as sensitive variables

variable "jamf_instance_fqdn" {
  description = "Jamf Pro instance URL"
  type        = string
  sensitive   = false  # URL is not sensitive
}

variable "jamf_client_id" {
  description = "Jamf Pro API client ID"
  type        = string
  sensitive   = false  # Client ID is not sensitive (like a username)
}

variable "jamf_client_secret" {
  description = "Jamf Pro API client secret"
  type        = string
  sensitive   = true
}

variable "google_oidc_client_id" {
  description = "Google OAuth 2.0 Client ID for Jamf Connect"
  type        = string
  sensitive   = true
}

variable "jamf_connect_license_base64" {
  description = "Base64-encoded Jamf Connect license plist"
  type        = string
  sensitive   = true
}
