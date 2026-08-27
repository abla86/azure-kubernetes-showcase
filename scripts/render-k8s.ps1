param(
  [string]$TerraformDir = (Join-Path $PSScriptRoot "..\infra\terraform"),
  [string]$OutputDir = (Join-Path $PSScriptRoot "..\.rendered-k8s")
)

$ErrorActionPreference = "Stop"

$clientId = terraform -chdir=$TerraformDir output -raw workload_identity_client_id
$subnetId = terraform -chdir=$TerraformDir output -raw vnet_id

if ([string]::IsNullOrWhiteSpace($clientId)) { throw "workload_identity_client_id is empty." }
if ([string]::IsNullOrWhiteSpace($subnetId)) { throw "vnet_id is empty. Use the networking subnet output when configuring Application Gateway for Containers." }

if (Test-Path $OutputDir) { Remove-Item $OutputDir -Recurse -Force }
Copy-Item (Join-Path $PSScriptRoot "..\k8s") $OutputDir -Recurse

Get-ChildItem $OutputDir -Recurse -File | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  $content = $content.Replace('__AZURE_WORKLOAD_IDENTITY_CLIENT_ID__', $clientId)
  $content = $content.Replace('__ALB_SUBNET_ID__', $subnetId)
  Set-Content $_.FullName $content
}

Write-Host "Rendered Kubernetes manifests to $OutputDir"
