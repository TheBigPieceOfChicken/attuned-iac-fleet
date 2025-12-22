# Terraform Provider Configuration
# This file configures providers for the Jamf Pro NFR tenant infrastructure

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.1.0"
    }
    
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Google Provider with Workload Identity Federation (OIDC)
# Authenticates using the Scalr OIDC provider - no hardcoded credentials
provider "google" {
  project = "jamf-pro-oidc-480503"
  region  = "us-central1"
}

# Data sources to fetch secrets from Google Secret Manager
data "google_secret_manager_secret_version" "jamf_url" {
  secret  = "jamf-url"
  project = "jamf-pro-oidc-480503"
}

data "google_secret_manager_secret_version" "jamf_client_id" {
  secret  = "jamf-client-id"
  project = "jamf-pro-oidc-480503"
}

data "google_secret_manager_secret_version" "jamf_client_secret" {
  secret  = "jamf-client-secret"
  project = "jamf-pro-oidc-480503"
}

# Jamf Pro Provider - uses secrets from GCP Secret Manager
provider "jamfpro" {
  instance_name = data.google_secret_manager_secret_version.jamf_url.secret_data
  client_id     = data.google_secret_manager_secret_version.jamf_client_id.secret_data
  client_secret = data.google_secret_manager_secret_version.jamf_client_secret.secret_data
  auth_method   = "oauth2"
}
