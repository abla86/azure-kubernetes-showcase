output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "vnet_id" { value = module.networking.vnet_id }
output "aks_name" { value = module.aks.aks_name }
output "aks_cluster_id" { value = module.aks.aks_cluster_id }
output "acr_name" { value = module.acr.acr_name }
output "oidc_issuer_url" { value = module.aks.oidc_issuer_url }
output "workload_identity_client_id" { value = module.iam.workload_identity_client_id }
