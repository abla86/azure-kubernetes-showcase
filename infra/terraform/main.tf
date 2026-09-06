resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    project     = "azure-kubernetes-showcase"
    environment = var.environment
  }
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  subnet_id            = module.networking.subnet_id
  kubernetes_version   = var.kubernetes_version
  node_count           = var.node_count
  node_vm_size         = var.node_vm_size
}

resource "azurerm_application_insights" "app" {
  name                = "appi-showcase-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = module.aks.log_analytics_workspace_id
  tags = {
    project     = "azure-kubernetes-showcase"
    environment = var.environment
  }
}

module "iam" {
  source                          = "./modules/iam"
  acr_id                          = module.acr.acr_id
  principal_id                    = module.aks.kubelet_identity_object_id
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  environment                     = var.environment
  oidc_issuer_url                 = module.aks.oidc_issuer_url
  application_insights_id         = azurerm_application_insights.app.id
  github_actions_principal_object_id = var.github_actions_principal_object_id
}
