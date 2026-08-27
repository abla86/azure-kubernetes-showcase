# IaC Parity Matrix

This matrix defines the intended parity between the Terraform and Bicep implementations. It is a review contract: a row is only considered complete when both implementations expose the same architectural intent and security boundary.

| Capability | Terraform | Bicep | Parity requirement |
|---|---|---|---|
| Resource group | `azurerm_resource_group` | resource group module/resource | Same environment/location intent |
| AKS | `azurerm_kubernetes_cluster` | AKS resource/module | Same cluster role and environment intent |
| AKS managed identity | System-assigned identity | System-assigned identity | Required |
| RBAC | `role_based_access_control_enabled = true` | RBAC enabled | Required |
| OIDC issuer | `oidc_issuer_enabled = true` | OIDC enabled | Required |
| Workload Identity | `workload_identity_enabled = true` + federated credential | Workload Identity/OIDC configuration | Required for pod-to-Azure authentication |
| Azure CNI | `network_plugin = "azure"` | Azure CNI networking | Required |
| Azure Network Policy | `network_policy = "azure"` | Azure network policy | Required |
| ACR | `azurerm_container_registry` | ACR resource | Same non-admin posture |
| ACR admin | `admin_enabled = false` | Admin disabled | Required |
| AKS → ACR | `AcrPull` role assignment to kubelet identity | Equivalent role assignment | Required |
| Log Analytics | `azurerm_log_analytics_workspace` | Log Analytics workspace | Required |
| Application Insights | `azurerm_application_insights` | Application Insights | Required where observability is enabled |
| Environment tagging | `project` / `environment` tags | equivalent tags | Required |

## Security invariants

Both IaC implementations must preserve these invariants:

- No hard-coded cloud credentials.
- AKS workload identity is separate from kubelet identity.
- ACR admin access remains disabled.
- Kubernetes RBAC remains enabled.
- Network policy remains enabled.
- The production deployment path must not rely on `latest` as the only image identifier.
- Runtime claims must be documented separately from IaC-only configuration.

## Verification rule

Parity is not proven by matching filenames or resource counts. CI should validate that both implementations compile/lint and that every row marked `Required` remains represented in both implementations.
