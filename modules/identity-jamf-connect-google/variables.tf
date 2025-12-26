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
