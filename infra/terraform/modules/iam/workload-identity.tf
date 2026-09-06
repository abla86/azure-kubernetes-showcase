variable "workload_identity_name" {
  description = "Name of the user-assigned managed identity for the API workload."
  type        = string
  default     = "id-aks-workload-api"
}

variable "workload_identity_subject" {
  description = "Kubernetes service account subject allowed to federate to the managed identity."
  type        = string
  default     = "system:serviceaccount:showcase:api-workload-identity-sa"
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = var.workload_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "api" {
  name                = "fic-api-workload"
  user_assigned_identity_id = azurerm_user_assigned_identity.workload.id
  issuer              = var.oidc_issuer_url
  audience            = ["api://AzureADTokenExchange"]
  subject             = var.workload_identity_subject
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}
