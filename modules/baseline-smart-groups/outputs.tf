output "smart_group_ids" {
  description = "Map of smart group keys to their Jamf Pro IDs"
  value       = { for k, v in jamfpro_smart_computer_group.groups : k => v.id }
}

output "smart_group_names" {
  description = "Map of smart group keys to their names"
  value       = { for k, v in jamfpro_smart_computer_group.groups : k => v.name }
}
