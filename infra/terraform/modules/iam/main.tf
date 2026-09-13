variable "acr_id" {
  type = string
}

variable "principal_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "application_insights_id" {
  type = string
}

variable "github_actions_principal_object_id" {
  type     = string
  nullable = true
  default  = null
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "appinsights_publish" {
  scope                = var.application_insights_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_role_assignment" "acr_push" {
  count                = var.github_actions_principal_object_id != null ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPush"
  principal_id         = var.github_actions_principal_object_id
}
