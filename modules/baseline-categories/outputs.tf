output "category_ids" {
  description = "Map of category keys to their Jamf Pro IDs"
  value       = { for k, v in jamfpro_category.categories : k => v.id }
}

output "category_names" {
  description = "Map of category keys to their names"
  value       = { for k, v in jamfpro_category.categories : k => v.name }
}
