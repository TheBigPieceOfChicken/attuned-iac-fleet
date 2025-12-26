terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.30.0"
    }
  }
}

resource "jamfpro_smart_computer_group" "groups" {
  for_each = var.smart_groups

  name = each.value.name

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      name          = criteria.value.name
      priority      = criteria.value.priority
      and_or        = criteria.value.and_or
      search_type   = criteria.value.search_type
      value         = criteria.value.value
      opening_paren = criteria.value.opening_paren
      closing_paren = criteria.value.closing_paren
    }
  }
}
