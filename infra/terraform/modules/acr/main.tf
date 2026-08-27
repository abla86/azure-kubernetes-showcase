variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "name_prefix" { type = string }

resource "azurerm_container_registry" "main" {
  name = replace("${var.name_prefix}acr", "-", "")
  location = var.location
  resource_group_name = var.resource_group_name
  sku = "Basic"
  admin_enabled = false
}

output "acr_id" { value = azurerm_container_registry.main.id }
output "acr_login_server" { value = azurerm_container_registry.main.login_server }
