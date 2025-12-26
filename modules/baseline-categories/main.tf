terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.30.0"
    }
  }
}

resource "jamfpro_category" "categories" {
  for_each = var.categories

  name     = each.value.name
  priority = each.value.priority
}
