module "networking" {
  source = "./modules/networking"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix = var.name_prefix
  vnet_address_space = var.vnet_address_space
  aks_subnet_prefix = var.aks_subnet_prefix
  workload_subnet_prefix = var.workload_subnet_prefix
}

module "acr" {
  source = "./modules/acr"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix = var.name_prefix
}

module "aks" {
  source = "./modules/aks"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix = var.name_prefix
  subnet_id = module.networking.aks_subnet_id
  node_count = var.node_count
  node_vm_size = var.node_vm_size
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

module "iam" {
  source = "./modules/iam"
  resource_group_name = azurerm_resource_group.main.name
  aks_identity_principal_id = module.aks.aks_identity_principal_id
  acr_id = module.acr.acr_id
  aks_oidc_issuer_url = module.aks.oidc_issuer_url
  workload_identity_name = "${var.name_prefix}-workload"
  workload_service_account = "showcase-api"
  workload_namespace = "showcase"
}

resource "azurerm_resource_group" "main" {
  name = var.resource_group_name
  location = var.location
  tags = { project = "azure-kubernetes-showcase" environment = "demo" }
}

resource "azurerm_log_analytics_workspace" "main" {
  name = "${var.name_prefix}-logs"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku = "PerGB2018"
  retention_in_days = 30
}
