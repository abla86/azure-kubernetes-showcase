# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)

A public cloud-engineering portfolio project demonstrating **.NET 10, React/TypeScript, Docker, Kubernetes, Azure, Infrastructure as Code, CI/CD, DevSecOps and observability**.

> **Portfolio status:** Public repository and deployment-ready infrastructure showcase. Azure deployment is intentionally opt-in because it creates billable cloud resources. Runtime deployment claims are not made until an actual Azure/AKS environment has been provisioned and verified.

## What this project demonstrates

- ASP.NET Core / .NET 10 APIs
- React + TypeScript + Vite
- Modular service boundaries
- Multi-stage, non-root Docker images
- Kubernetes Deployments, Services, probes, HPA and NetworkPolicy
- Restricted Pod Security
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure Bicep and modular Terraform
- AKS OIDC / Workload Identity
- GitHub Actions CI/CD
- CodeQL, Dependabot, Trivy and SBOM generation
- OpenTelemetry and Azure Monitor integration points
- Automated API security self-tests
- Controlled Kubernetes resilience testing
- IaC validation and parity checks
- Day-2 diagnostic documentation

## Architecture

```text
Developer / Pull Request
          |
          v
    GitHub Actions
   /  |  |  |  \
  v   v  v  v   v
Build Test CodeQL Trivy SBOM
          |
          v
       Azure ACR
          |
          v
        Argo CD
          |
          v
         AKS
          |
     +----+----+----+
     |    |    |    |
    Core Care Community Security
     API Portal   Hub    Radar
          |
          v
 NetworkPolicy / Pod Security
          |
          v
 OpenTelemetry -> Azure Monitor
```

## Application modules

### Core Showcase API
`src/Showcase.Api/`

The main .NET API containing health, information, metrics and example event endpoints.

### Care Portal
`apps/care-portal/CarePortal.Api/`

A deliberately small demonstration service for service-boundary and API design. It contains no patient data and uses demonstration data only.

### Community Hub
`apps/community-hub/CommunityHub.Api/`

A small demonstration service for shared-resource scenarios. It contains no real personal data.

### Security Radar
`apps/security-radar/`

A controlled security/operations demonstration with a local event feed, bounded-delay simulation, rate limiting and an application-level test route. It is **not** presented as a production SIEM or intrusion-detection platform.

## Local verification

### Prerequisites

- .NET 10 SDK
- Node.js 22+
- Docker Desktop
- Python 3.12+
- kubectl
- Azure CLI and Terraform for infrastructure work

### Build and test

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release

cd src/Web
npm ci
npm run lint
npm run build
cd ../..

python scripts/local_smoke_test.py
```

### Run the local stack

```powershell
docker compose up --build
```

Then the local services are available on the ports documented by the Compose configuration. The canonical smoke test starts the stack, verifies health and security behavior, and tears the stack down afterwards.

## Kubernetes

The `k8s/` directory contains the Kubernetes deployment model, including:

- Namespace and workloads
- Services
- startup/readiness/liveness probes
- HPA
- Gateway API routes
- Workload Identity ServiceAccount configuration
- default-deny NetworkPolicies with required DNS egress
- restricted workload security settings

`scripts/validate_manifests.py` checks the declared workload security controls, including non-root execution, privilege-escalation prevention, read-only filesystems, dropped capabilities and seccomp configuration.

## Azure Infrastructure as Code

Terraform is organized into networking, ACR, AKS and IAM/Workload Identity modules. The AKS configuration uses OIDC and Workload Identity and is designed around Azure CNI Overlay with Azure Network Policy.

Bicep is retained as a second IaC representation. CI compiles Bicep and validates Terraform without requiring an Azure deployment.

### Important deployment boundary

The repository does **not** claim that Azure resources exist merely because Terraform or Bicep files exist. An actual deployment requires an Azure subscription and correctly configured GitHub OIDC trust, state storage and repository variables/secrets.

The deployment workflow is manual and supports `plan` and `apply`. `apply` must remain an explicit operator action because it can create billable Azure resources.

## GitHub Actions / DevSecOps

The repository contains workflows for:

1. .NET restore, build and tests
2. Frontend lint and build
3. Kubernetes manifest/security validation
4. Bicep compilation
5. Terraform formatting and validation
6. Container builds
7. Trivy vulnerability scanning
8. CycloneDX SBOM generation
9. CodeQL analysis
10. Checkov IaC checks
11. Kubeconform schema validation
12. IaC parity-contract checks
13. Local API security self-testing
14. Canonical local smoke testing
15. Repository maintenance and documentation checks
16. Explicitly triggered AKS resilience testing

GitHub's Azure deployment documentation recommends an existing AKS/ACR target and authenticated Azure credentials for deployment workflows. This repository uses Azure OIDC rather than committing long-lived Azure credentials. citeturn0search0

## Security architecture

| Layer | Control | Purpose |
|---|---|---|
| Source | CodeQL, Dependabot | Static analysis and dependency monitoring |
| Build | Trivy, SBOM, Checkov | Supply-chain and IaC checks |
| Container | Non-root, read-only filesystem, dropped capabilities | Runtime hardening |
| Kubernetes | Restricted Pod Security, seccomp, probes | Workload hardening |
| Network | Default-deny NetworkPolicies | Explicit communication boundaries |
| Identity | OIDC / Workload Identity | Avoid stored cloud credentials |
| Configuration | Kubeconform and policy validation | Prevent invalid manifests/configuration |
| Runtime | OpenTelemetry and runbooks | Observability and diagnosis |
| Resilience | Controlled pod deletion/reconciliation test | Verifiable recovery behavior |

No credentials, production data or patient information are included.

## Resilience testing

`.github/workflows/chaos.yml` provides an explicitly triggered, bounded resilience test. It is designed to authenticate to AKS using OIDC, delete a selected workload pod and verify Kubernetes reconciliation.

This workflow should only be run against an intentionally provisioned showcase environment.

## Day-2 operations

See `docs/observability-runbook.md` for the diagnostic path from routing and NetworkPolicy through pod health, application logs and telemetry.

The repository also contains `k8s-pod-doctor` for first-line diagnosis of common pod failures such as `CrashLoopBackOff` and `OOMKilled`.

## Cost controls

Terraform contains a configurable resource-group budget guardrail. Budget thresholds and notification recipients are variables rather than hardcoded secrets.

**Important:** a budget configuration is a guardrail, not a guarantee of zero Azure cost.

## Verification discipline

The project deliberately separates:

- **configuration** — what the repository declares;
- **static verification** — what CI can validate without Azure;
- **local runtime verification** — what Docker Compose and local tests demonstrate;
- **cloud runtime verification** — what can only be demonstrated after deployment to Azure/AKS.

A configuration file is never treated as proof that a cloud resource or runtime behavior exists.

## Portfolio scope

This is a **cloud-engineering portfolio showcase**, not a production healthcare or community-management platform. The application modules are intentionally small so that the engineering concerns around containers, Kubernetes, Azure, IaC, CI/CD, security and observability remain visible.

## Repository quality

The repository includes:

- `SECURITY.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `CHANGELOG.md`
- architecture and operational documentation
- automated maintenance checks
- reproducible local verification commands

## Repository

https://github.com/abla86/azure-kubernetes-showcase

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.
