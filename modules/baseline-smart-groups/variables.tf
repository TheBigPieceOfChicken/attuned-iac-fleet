variable "smart_groups" {
  description = "Map of smart computer groups to create"
  type = map(object({
    name = string
    criteria = list(object({
      name          = string
      priority      = number
      and_or        = string
      search_type   = string
      value         = string
      opening_paren = optional(bool, false)
      closing_paren = optional(bool, false)
    }))
  }))
  default = {
    "all-managed-macs" = {
      name = "All Managed Macs"
      criteria = [{
        name          = "Computer Group"
        priority      = 0
        and_or        = "and"
        search_type   = "not member of"
        value         = "Excluded from Management"
        opening_paren = false
        closing_paren = false
      }]
    }
    "macos-sequoia" = {
      name = "macOS Sequoia (15.x)"
      criteria = [{
        name          = "Operating System Version"
        priority      = 0
        and_or        = "and"
        search_type   = "like"
        value         = "15."
        opening_paren = false
        closing_paren = false
      }]
    }
    "macos-sonoma" = {
      name = "macOS Sonoma (14.x)"
      criteria = [{
        name          = "Operating System Version"
        priority      = 0
        and_or        = "and"
        search_type   = "like"
        value         = "14."
        opening_paren = false
        closing_paren = false
      }]
    }
  }
}
