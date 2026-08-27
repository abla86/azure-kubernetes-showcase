variable "resource_group_name" { type = string }
variable "aks_identity_principal_id" { type = string }
variable "acr_id" { type = string }
variable "aks_oidc_issuer_url" { type = string }
variable "workload_identity_name" { type = string }
variable "workload_service_account" { type = string }
variable "workload_namespace" { type = string }

resource "azurerm_role_assignment" "acr_pull" {
  scope = var.acr_id
  role_definition_name = "AcrPull"
  principal_id = var.aks_identity_principal_id
}

resource "azurerm_user_assigned_identity" "workload" {
  name = var.workload_identity_name
  location = "westeurope"
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "workload" {
  name = "${var.workload_identity_name}-fic"
  resource_group_name = var.resource_group_name
  parent_id = azurerm_user_assigned_identity.workload.id
  issuer = var.aks_oidc_issuer_url
  subject = "system:serviceaccount:${var.workload_namespace}:${var.workload_service_account}"
  audience = ["api://AzureADTokenExchange"]
}

output "workload_identity_client_id" { value = azurerm_user_assigned_identity.workload.client_id }
