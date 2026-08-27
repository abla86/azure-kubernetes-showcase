variable "acr_id" { type = string }
variable "principal_id" { type = string }

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}

# Workload Identity is intentionally separate from the AKS kubelet identity.
# The kubelet identity is used for node-level ACR image pulls; workload identity
# should use a dedicated user-assigned managed identity with OIDC federation.
variable "workload_identity_principal_id" {
  description = "Principal ID of the dedicated user-assigned managed identity used by application workloads."
  type        = string
  default     = null
  nullable    = true
}

variable "workload_identity_scope" {
  description = "Optional Azure resource scope for the workload identity role assignment."
  type        = string
  default     = null
  nullable    = true
}

variable "workload_identity_role_definition_name" {
  description = "Azure RBAC role for the workload identity when a scope is supplied."
  type        = string
  default     = "Reader"
}

resource "azurerm_role_assignment" "workload_identity" {
  count                = var.workload_identity_principal_id != null && var.workload_identity_scope != null ? 1 : 0
  scope                = var.workload_identity_scope
  role_definition_name = var.workload_identity_role_definition_name
  principal_id         = var.workload_identity_principal_id
}
