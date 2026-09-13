param(
  [string]$ClientId = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "k8s\workload-identity.yaml"
$output = Join-Path $root "k8s\generated-workload-identity.yaml"

if (-not $ClientId) {
  Push-Location (Join-Path $root "infra\terraform")
  try {
    $ClientId = (terraform output -raw workload_identity_client_id).Trim()
  }
  finally {
    Pop-Location
  }
}

if (-not $ClientId) {
  throw "Fant ikke workload identity client ID. Kjor terraform apply først, eller angi -ClientId."
}

$content = Get-Content $source -Raw
$content = $content.Replace('${AZURE_WORKLOAD_IDENTITY_CLIENT_ID}', $ClientId)
[System.IO.File]::WriteAllText($output, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Generert: $output" -ForegroundColor Green
