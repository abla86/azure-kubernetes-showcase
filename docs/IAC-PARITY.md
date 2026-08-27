# Terraform / Bicep parity

This matrix documents the intended equivalence between the two IaC implementations. `Verified` means the property is visibly represented in both source trees; it does **not** mean Azure runtime deployment has been executed.

| Capability | Terraform | Bicep | Verified |
|---|---|---|---|
| Resource group | `azurerm_resource_group` | `Microsoft.Resources/resourceGroups` | Review |
| AKS | `azurerm_kubernetes_cluster` | `Microsoft.ContainerService/managedClusters` | Yes |
| System-assigned AKS identity | `identity.type = SystemAssigned` | `identity.type = SystemAssigned` | Yes |
| OIDC issuer | `oidc_issuer_enabled = true` | `oidcIssuerProfile.enabled = true` | Yes |
| Workload Identity | `workload_identity_enabled = true` + federated credential | `securityProfile.workloadIdentity.enabled = true` | Partial: federated binding is Terraform-managed |
| Azure CNI | `network_plugin = "azure"` | `networkProfile.networkPlugin = "azure"` | Yes |
| Azure Network Policy | `network_policy = "azure"` | `networkProfile.networkPolicy = "azure"` | Yes |
| Standard load balancer | `load_balancer_sku = "standard"` | `loadBalancerSku = "standard"` | Yes |
| ACR | `azurerm_container_registry` | `Microsoft.ContainerRegistry/registries` | Yes |
| ACR admin disabled | `admin_enabled = false` | `adminUserEnabled = false` | Yes |
| AKS → ACR AcrPull | `azurerm_role_assignment` | role assignment resource | Yes |
| Log Analytics | `azurerm_log_analytics_workspace` | `Microsoft.OperationalInsights/workspaces` | Yes |
| Application Insights | `azurerm_application_insights` | Not present in current `main.bicep` | No |
| Agent/node size | `node_vm_size` | `agentVmSize` | Yes |
| Agent/node count | `node_count` | `agentCount` | Yes |

## Drift rule

A change to one IaC implementation that changes security-sensitive behavior MUST either:

1. make the equivalent change in the other implementation, or
2. document explicitly why the implementations intentionally differ.

## Runtime boundary

This document is a source-level parity contract. It does not claim that the Azure resources are currently deployed, reachable, or runtime-tested.
