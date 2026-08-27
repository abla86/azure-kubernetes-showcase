variable "location" {
  description = "Azure region for all resources."
  type = string
  default = "westeurope"
}
variable "resource_group_name" {
  description = "Resource group for the showcase."
  type = string
  default = "rg-azure-kubernetes-showcase"
}
variable "name_prefix" {
  description = "Lowercase resource naming prefix."
  type = string
  default = "azkshowcase"
}
variable "node_count" { type = number default = 2 }
variable "node_vm_size" { type = string default = "Standard_B2s" }
variable "vnet_address_space" { type = list(string) default = ["10.20.0.0/16"] }
variable "aks_subnet_prefix" { type = string default = "10.20.0.0/22" }
variable "workload_subnet_prefix" { type = string default = "10.20.4.0/22" }
variable "sites" {
  description = "Synthetic logical sites used by the multi-site model."
  type = set(string)
  default = ["house-01", "house-02", "house-03"]
}
