variable "acr_id" { type = string }
variable "principal_id" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "oidc_issuer_url" { type = string }
variable "application_insights_id" { type = string }
variable "github_actions_client_id" { type = string, nullable = true, default = null }

resource "azurerm_role_assignment" "acr_pull" {
  scope = var.acr_id
  role_definition_name = "AcrPull"
  principal_id = var.principal_id
}

resource "azurerm_user_assigned_identity" "workload" {
  name = "id-showcase-workload-\${var.environment}"
  location = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "workload" {
  name = "showcase-api-service-account"
  resource_group_name = var.resource_group_name
  parent_id = azurerm_user_assigned_identity.workload.id
  issuer = var.oidc_issuer_url
  subject = "system:serviceaccount:showcase:api-workload-identity-sa"
  audiences = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "appinsights_publish" {
  scope = var.application_insights_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_role_assignment" "acr_push" {
  count = var.github_actions_client_id != null ? 1 : 0
  scope = var.acr_id
  role_definition_name = "AcrPush"
  principal_id = var.github_actions_client_id
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}
