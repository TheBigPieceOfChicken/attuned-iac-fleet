variable "login_profile_name" {
  description = "Name for the Jamf Connect Login configuration profile"
  type        = string
  default     = "008-IDM-JamfConnect-Login-ALL"
}

variable "privilege_profile_name" {
  description = "Name for the Jamf Connect Privilege Elevation profile"
  type        = string
  default     = "009-IDM-JamfConnect-PrivilegeElevation-ALL"
}

variable "category_id" {
  description = "Category ID to assign to profiles"
  type        = number
  default     = -1
}

variable "enable_privilege_elevation" {
  description = "Whether to deploy the privilege elevation profile"
  type        = bool
  default     = true
}

variable "scope_all_computers" {
  description = "Scope profiles to all computers"
  type        = bool
  default     = false
}

variable "scope_smart_group_ids" {
  description = "List of smart group IDs to scope profiles to"
  type        = list(number)
  default     = []
}

variable "client" {
  description = "Client-specific configuration including licenses and IDP settings"
  type = object({
    name         = string
    organization = string

    jamf_connect = object({
      license_key     = string
      email           = string
      date_issued     = string
      expiration_date = string
      signature       = string
      edition         = string
      major_version   = number
      num_clients     = number
    })

    jamf_protect = object({
      tenant_id = string
    })

    google_idp = object({
      client_id = string
      tenant    = string
    })
  })
  sensitive = true
}
