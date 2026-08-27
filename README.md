# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)

A cloud-engineering portfolio project demonstrating .NET 10, React/TypeScript, Docker, Kubernetes, Azure IaC and DevSecOps.

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
Kubernetes / Nginx
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

The solution file includes the core API, Care Portal and Community Hub.

Compose ports:

| Service | Port |
|---|---:|
| Main API | 5080 |
| Frontend | 5173 |
| Care Portal | 5081 |
| Community Hub | 5082 |

## Kubernetes

The `k8s/` directory contains the namespace, application deployments, services, HPA, NetworkPolicies, probes and Workload Identity ServiceAccount configuration.

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
6. Docker builds for all four application containers
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