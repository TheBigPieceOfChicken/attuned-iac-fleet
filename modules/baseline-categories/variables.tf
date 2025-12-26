variable "categories" {
  description = "Map of categories to create in Jamf Pro"
  type = map(object({
    name     = string
    priority = number
  }))
  default = {
    "identity"       = { name = "Identity", priority = 1 }
    "security"       = { name = "Security", priority = 2 }
    "productivity"   = { name = "Productivity", priority = 3 }
    "utilities"      = { name = "Utilities", priority = 4 }
    "communication"  = { name = "Communication", priority = 5 }
    "management"     = { name = "Management", priority = 6 }
  }
}
