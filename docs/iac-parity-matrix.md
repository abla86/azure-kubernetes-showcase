# IaC Parity Matrix

This matrix defines the intended parity between the Terraform and Bicep implementations. It is a review contract: a row is only considered complete when both implementations expose the same architectural intent and security boundary.

| Capability | Terraform | Bicep | Status |
|---|---|---|---|
| Resource group | `azurerm_resource_group` | Resource group deployment context | Verified core parity |
| AKS | `azurerm_kubernetes_cluster` | `Microsoft.ContainerService/managedClusters` | Verified core parity |
| AKS managed identity | System-assigned identity | System-assigned identity | Verified |
| RBAC | `role_based_access_control_enabled = true` | AKS RBAC configuration | Verified |
| OIDC issuer | `oidc_issuer_enabled = true` | `oidcIssuerProfile.enabled = true` | Verified |
| Workload Identity | Workload identity enabled + federated credential | Workload identity enabled | Partial: live federation requires runtime verification |
| Azure CNI | Azure network plugin | Azure network plugin | Verified |
| Azure Network Policy | `network_policy = "azure"` | `networkPolicy = "azure"` | Verified |
| ACR | `azurerm_container_registry` | ACR resource | Verified core parity |
| ACR admin | `admin_enabled = false` | `adminUserEnabled = false` | Verified |
| AKS → ACR | `AcrPull` role assignment to kubelet identity | Equivalent role assignment | Verified in source |
| Log Analytics | `azurerm_log_analytics_workspace` | Log Analytics workspace | Verified |
| Application Insights | `azurerm_application_insights` | Not currently provisioned | Documented exception |
| Environment tagging | `project` / `environment` | Project/environment metadata | Partial: implementation details differ |

## Deliberate parity exception

### Application Insights

Terraform currently provisions Application Insights and passes its resource ID into the IAM module. The current Bicep implementation provisions Log Analytics but does not provision an equivalent Application Insights resource.

This is intentionally documented as an exception rather than being reported as full parity.

**Decision:** keep the exception until an equivalent Bicep implementation is added and validated.

**Current evidence:** repository source only. Live Azure equivalence is not claimed.

## Security invariants

Both IaC implementations must preserve these invariants:

- No hard-coded cloud credentials.
- AKS workload identity is distinct from kubelet identity.
- ACR admin access remains disabled.
- Kubernetes RBAC remains enabled.
- Network policy remains enabled.
- Deployment images should use immutable identifiers such as a commit SHA rather than relying on `latest` alone.
- Runtime claims must be documented separately from IaC-only configuration.

## Verification rule

Parity is not proven by matching filenames or resource counts. CI should validate that both implementations compile/lint and that every required capability is represented in both implementations, while explicitly allowing documented exceptions.
