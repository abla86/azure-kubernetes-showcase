variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "name_prefix" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "aks_subnet_prefix" { type = string }
variable "workload_subnet_prefix" { type = string }

resource "azurerm_virtual_network" "main" {
  name = "${var.name_prefix}-vnet"
  location = var.location
  resource_group_name = var.resource_group_name
  address_space = var.vnet_address_space
}

resource "azurerm_subnet" "aks" {
  name = "snet-aks"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.aks_subnet_prefix]
}

resource "azurerm_subnet" "workloads" {
  name = "snet-workloads"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.workload_subnet_prefix]
}

output "aks_subnet_id" { value = azurerm_subnet.aks.id }
output "workload_subnet_id" { value = azurerm_subnet.workloads.id }
