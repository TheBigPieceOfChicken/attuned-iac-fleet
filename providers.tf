# Terraform Provider Configuration
# This file configures providers for the Jamf Pro NFR tenant infrastructure

terraform {
  required_version = ">= 1.0"

  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.1.0"
    }
  }
}

# Jamf Pro Provider - uses secrets from Scalr variables
provider "jamfpro" {
  jamfpro_instance_fqdn = var.jamf_url
  client_id     = var.jamf_client_id
  client_secret = var.jamf_client_secret
  auth_method   = "oauth2"
}
