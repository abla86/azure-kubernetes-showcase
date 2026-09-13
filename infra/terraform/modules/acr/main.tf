variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

resource "azurerm_container_registry" "acr" {
  name                      = "acrshowcase${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku                       = "Premium"
  admin_enabled             = false
  anonymous_pull_enabled    = false
  data_endpoint_enabled     = true
  quarantine_policy_enabled = true
  retention_policy_in_days  = 7
  zone_redundancy_enabled   = true
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}
