param(
  [string]$TerraformDir = (Join-Path $PSScriptRoot "..\infra\terraform"),
  [string]$OutputDir = (Join-Path $PSScriptRoot "..\.rendered-k8s"),
  [string]$ImageTag = $env:IMAGE_TAG,
  [string]$AppHostname = $env:APP_HOSTNAME,
  [string]$CertManagerEmail = $env:CERT_MANAGER_EMAIL
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ImageTag)) { throw "ImageTag is empty. Set IMAGE_TAG or pass -ImageTag." }
if ([string]::IsNullOrWhiteSpace($AppHostname)) { throw "AppHostname is empty. Set APP_HOSTNAME or pass -AppHostname." }
if ([string]::IsNullOrWhiteSpace($CertManagerEmail)) { throw "CertManagerEmail is empty. Set CERT_MANAGER_EMAIL or pass -CertManagerEmail." }

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
  $content = $content.Replace('${IMAGE_TAG}', $ImageTag)
  $content = $content.Replace('__APP_HOSTNAME__', $AppHostname)
  $content = $content.Replace('__CERT_MANAGER_EMAIL__', $CertManagerEmail)
  Set-Content $_.FullName $content -NoNewline
}

Write-Host "Rendered Kubernetes manifests to $OutputDir using image tag $ImageTag and hostname $AppHostname"
