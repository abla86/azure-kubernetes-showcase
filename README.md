# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)

A cloud-engineering portfolio project demonstrating .NET 10, React/TypeScript, Docker, Kubernetes, Azure IaC and DevSecOps, with deliberately small application services and controlled resilience/security demonstrations.

## What it demonstrates

- ASP.NET Core / .NET 10 APIs
- React + TypeScript + Vite
- Core Showcase API, Care Portal and Community Hub modules
- Multi-stage non-root Docker containers
- Kubernetes Deployments, Services, probes, HPA and NetworkPolicy
- Restricted Pod Security
- Azure Bicep and modular Terraform
- AKS OIDC / Workload Identity
- ACR pull permissions
- GitHub Actions CI
- CodeQL and Dependabot
- Health endpoints, Serilog and OpenTelemetry in the core API
- Security Radar for controlled security-event simulation

## Application modules

### Core Showcase API
`src/Showcase.Api/`

The original portfolio API with health, information, metrics and example event endpoints.

### Care Portal
`apps/care-portal/CarePortal.Api/`

A small demonstration service for care-coordination concepts. It contains no patient data and uses in-memory example data only.

### Community Hub
`apps/community-hub/CommunityHub.Api/`

A small demonstration service for shared resources. It contains no real personal data and uses in-memory example data only.

## Architecture

```text
React/TypeScript frontend
        |
        v
Kubernetes / Gateway API
        |
        +--> Core Showcase API
        +--> Care Portal
        +--> Community Hub
        |
        +--> NetworkPolicy + Restricted Pod Security
        |
        +--> OIDC / Workload Identity
        |
        v
Azure Container Registry
        |
        v
Terraform / Bicep
```

## Local development

Prerequisites: .NET 10 SDK, Node.js 22+, Docker Desktop, kubectl and optionally Azure CLI/Terraform.

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release
docker compose up --build
```

The local Compose stack intentionally contains the three application services below. The core API/frontend remain available through their existing project-specific development workflows.

Compose ports:

| Service | Port |
|---|---:|
| Security Radar | 5080 |
| Care Portal | 5001 |
| Community Hub | 5002 |

Start the Compose stack with:

```powershell
docker compose up --build
```

The Security Radar's simulation is controlled application behavior; it is not presented as a real SIEM, IDS or attack generator.

## Kubernetes

The `k8s/` directory contains the namespace, application deployments, services, HPA, NetworkPolicies, probes, Gateway API routes and Workload Identity ServiceAccount configuration.

CI uses client-side parsing without requiring a live cluster:

```powershell
kubectl apply --dry-run=client --validate=false -f k8s/
```

A successful manifest parse is not treated as proof of a production deployment.

## Azure IaC

Terraform is modularized into networking, ACR, AKS and IAM/Workload Identity. The AKS configuration enables OIDC and Workload Identity, uses Azure networking/policy settings and grants the kubelet identity ACR pull access.

Bicep remains available as a second IaC representation.

The repository does not claim that Azure resources are deployed merely because the configuration exists. Deployment may create billable resources.

## CI / DevSecOps

GitHub Actions checks:

1. .NET restore, build and tests
2. Frontend install, lint and build
3. Kubernetes manifest parsing
4. Bicep compilation
5. Terraform format, initialization and validation
6. Docker builds for all five application containers
7. CodeQL analysis

## Security

- Non-root runtime containers
- Explicit UID 1654 for .NET containers
- `runAsNonRoot`
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- Capabilities dropped with `ALL`
- Restricted Pod Security labels
- NetworkPolicy isolation
- OIDC / Workload Identity configuration
- ACR pull through managed identity
- CodeQL and Dependabot

No credentials, production data or patient information are included.

## Verification status

Automated CI checks are the authoritative verification for committed source. A failed check is not described as successful functionality. A real Azure/AKS deployment requires a separate deployment and runtime verification.

## Scope

This is a portfolio showcase, not a production healthcare or community-management system. The modules are intentionally small demonstrations of service boundaries, containers, Kubernetes and Azure infrastructure.

## Repository

https://github.com/abla86/azure-kubernetes-showcase

## Enterprise delivery layer

The repository also contains the production-oriented delivery patterns below.

### Observability

The .NET services use OpenTelemetry instrumentation for ASP.NET Core, HTTP client and runtime metrics. Azure Monitor's OpenTelemetry exporter is configured with `DefaultAzureCredential`, so AKS Workload Identity can authenticate telemetry without embedding an Application Insights connection string in the repository.

Terraform provisions Application Insights on the existing Log Analytics workspace and grants the dedicated workload identity the **Monitoring Metrics Publisher** role. Microsoft documents this role as the required ingestion permission for Entra-authenticated Application Insights telemetry. 

### GitOps and Kubernetes delivery

`k8s/kustomization.yaml` is the deployment root for Kustomize. `k8s/gitops/application.yaml` defines an Argo CD Application that tracks the `main` branch and enables automated sync, pruning and self-healing.

The repository uses Kubernetes Gateway API rather than adding a new dependency on the legacy NGINX ingress controller. The intended Azure ingress implementation is **Application Gateway for Containers / ALB Controller**, with HTTPS listeners and cert-manager-managed certificates.

The Gateway manifests contain example domain values and therefore require a real DNS name and ACME email before public certificate issuance. They are not presented as a live public endpoint until those values are configured.

### Supply-chain security

`.github/workflows/build-scan-publish.yml` builds the application container images defined in its matrix, scans each image with Trivy for HIGH/CRITICAL vulnerabilities, uploads SARIF results and publishes a CycloneDX SBOM artifact.

Only the exact locally loaded image that passes the build/scan step is pushed; the workflow does not rebuild a different image between scanning and publication. Publishing uses Azure Login with GitHub OIDC and ACR RBAC; no ACR admin credentials are used.

### Terraform delivery

`.github/workflows/terraform-deploy.yml` provides an OIDC-based plan/apply path with an Azure Storage remote state backend using Microsoft Entra authentication.

The workflow expects the Azure identity and Terraform-state storage configuration to be supplied through GitHub Environment secrets/variables. It is intentionally not described as a successful Azure deployment until a real workflow run completes successfully.

## Required external configuration

Before a real cloud deployment, configure:

- GitHub Environment `production`
- `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` secrets
- `ACR_NAME` and `ACR_LOGIN_SERVER` repository/environment variables
- `TFSTATE_RESOURCE_GROUP`, `TFSTATE_STORAGE_ACCOUNT` and `TFSTATE_CONTAINER` variables
- Azure federated identity credentials for the GitHub repository/workflow
- Azure Storage Blob Data Contributor permission for Terraform state
- A real DNS name and ACME email for public TLS
- Application Gateway for Containers / ALB Controller prerequisites

These are deployment prerequisites, not fake values committed as secrets.

## Verification discipline

A workflow file existing in GitHub is not evidence that the corresponding Azure resource or Kubernetes workload is deployed. Deployment, runtime health, telemetry ingestion, TLS issuance and GitOps synchronization are only marked as operational after a successful environment-specific verification.


## Resilience and security demonstrations

### Controlled chaos test

`.github/workflows/chaos.yml` provides an explicitly manual resilience test. After authenticating to AKS through GitHub OIDC, it deletes one selected application pod and verifies that the Deployment reaches its desired state again. This is a controlled recovery test, not evidence of a measured sub-two-second SLA.

### Security Radar

`apps/security-radar/` provides a small visual operations surface with a controlled simulation endpoint. The endpoint deliberately waits before rejecting the simulated request and reports the measured delay. It demonstrates application-level detection and response behavior without generating real malicious traffic.

### Deception layer

The Security Radar now contains a **controlled application-level deception layer**: a `/ghost/{path}` decoy route records a local event, applies a bounded delay, and rejects the request. It does not collect client IP addresses, contact external systems, or represent a production deception network. Real SIEM ingestion and live NetworkPolicy/IP-block visualization still require runtime telemetry integration.

## Verification matrix

| Capability | Source implementation | Runtime proof required |
|---|---|---|
| Container build | GitHub Actions | CI success |
| Vulnerability scanning | Trivy | CI success with policy threshold |
| SBOM | CycloneDX artifact | CI artifact |
| IaC security | Checkov | CI success |
| Kubernetes schema validation | Kubeconform | CI success |
| Pod recovery | Chaos workflow | Successful AKS run |
| OIDC authentication | GitHub/Azure configuration | Successful Azure login |
| ACR publication | GitHub/Azure configuration | Successful push |
| OpenTelemetry ingestion | App + Azure configuration | Runtime telemetry observed |
| TLS | Gateway/cert-manager manifests | Issued certificate + HTTPS test |
| GitOps synchronization | Argo CD manifest | Argo CD application healthy/synced |

This matrix prevents configuration from being presented as runtime evidence.
