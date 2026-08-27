variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }

resource "azurerm_container_registry" "acr" {
  name                = "acrshowcase${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

output "acr_id" { value = azurerm_container_registry.acr.id }
output "acr_name" { value = azurerm_container_registry.acr.name }
