# Variables for Jamf Pro Terraform Configuration
# These are set in Scalr workspace as sensitive variables

variable "jamf_url" {
  description = "Jamf Pro instance URL"
  type        = string
  sensitive   = true
}

variable "jamf_client_id" {
  description = "Jamf Pro API client ID"
  type        = string
  sensitive   = true
}

variable "jamf_client_secret" {
  description = "Jamf Pro API client secret"
  type        = string
  sensitive   = true
}

variable "google_oauth_client_id" {
  description = "Google OAuth Client ID for Jamf Connect"
  type        = string
  sensitive   = true
}

variable "google_oauth_client_secret" {
  description = "Google OAuth Client Secret for Jamf Connect"
  type        = string
  sensitive   = true
}
