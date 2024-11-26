output "id" {
  value = azurerm_linux_web_app.this.id
}

output "staging_slot_id" {
  value = var.staging_slot_enabled ? azurerm_linux_web_app_slot.staging[0].id : null
}

output "name" {
  value = azurerm_linux_web_app.this.name
}
