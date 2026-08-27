output "resource_group_name" { value = azurerm_resource_group.main.name }
output "aks_name" { value = module.aks.aks_name }
output "aks_id" { value = module.aks.aks_id }
output "acr_login_server" { value = module.acr.acr_login_server }
output "oidc_issuer_url" { value = module.aks.oidc_issuer_url }
output "workload_identity_client_id" { value = module.iam.workload_identity_client_id }
