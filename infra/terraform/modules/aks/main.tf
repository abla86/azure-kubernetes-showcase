variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "name_prefix" { type = string }
variable "subnet_id" { type = string }
variable "node_count" { type = number }
variable "node_vm_size" { type = string }
variable "log_analytics_workspace_id" { type = string }

resource "azurerm_kubernetes_cluster" "main" {
  name = "${var.name_prefix}-aks"
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = "${var.name_prefix}-aks"

  default_node_pool {
    name = "system"
    node_count = var.node_count
    vm_size = var.node_vm_size
    vnet_subnet_id = var.subnet_id
  }

  identity { type = "SystemAssigned" }

  oidc_issuer_enabled = true
  workload_identity_enabled = true
  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = { project = "azure-kubernetes-showcase" }
}

output "aks_id" { value = azurerm_kubernetes_cluster.main.id }
output "aks_name" { value = azurerm_kubernetes_cluster.main.name }
output "aks_identity_principal_id" { value = azurerm_kubernetes_cluster.main.identity[0].principal_id }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.main.oidc_issuer_url }
