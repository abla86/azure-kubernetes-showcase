variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.200.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "subnet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.200.1.0/24"]
}

output "subnet_id" { value = azurerm_subnet.aks_subnet.id }
output "vnet_id" { value = azurerm_virtual_network.vnet.id }
