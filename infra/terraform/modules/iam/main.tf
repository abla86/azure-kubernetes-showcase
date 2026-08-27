variable "acr_id" { type = string }
variable "principal_id" { type = string }

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}
