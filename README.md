# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)

A cloud-engineering portfolio project demonstrating .NET 10, React/TypeScript, Docker, Kubernetes, Azure IaC and DevSecOps, with deliberately small application services and controlled resilience/security demonstrations.

## Fast evaluation

**Test the application layer locally:**

```powershell
docker compose up --build
```

Then open Security Radar at `http://localhost:5080`, Care Portal at `http://localhost:5001` and Community Hub at `http://localhost:5002`.

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
- GitHub Actions CI/CD
- CodeQL, Dependabot, Trivy and SBOM generation
- OpenTelemetry and Azure Monitor integration
- Security Radar for controlled security-event simulation
- Automated local API security self-tests
- Controlled Kubernetes resilience testing

## Architecture

```text
Developer / PR
      |
      v
GitHub Actions
  |   |   |   |   |
  |   |   |   |   +--> SBOM
  |   |   |   +------> Trivy
  |   |   +----------> CodeQL
  |   +--------------> Checkov / Kubeconform
  +------------------> Build / Test
            |
            v
        ACR (OIDC)
            |
            v
          ArgoCD
            |
            v
           AKS
            |
    +-------+--------+
    |       |        |
    v       v        v
  Core    Care    Community
  API    Portal      Hub
            |
            +---- Security Radar
            |
            v
  NetworkPolicy / Restricted Pods
            |
            v
 OpenTelemetry -> Azure Monitor
```

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

### Security Radar
`apps/security-radar/`

A controlled operations/security demonstration with a local event feed, bounded-delay simulation endpoint and application-level ghost route. It does not claim to be a production SIEM or intrusion-detection platform.

## Local development

Prerequisites: .NET 10 SDK, Node.js 22+, Docker Desktop, kubectl and optionally Azure CLI/Terraform.

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release
docker compose up --build
```

The local Compose stack contains the three application services used for the defensive self-test plus Security Radar. The infrastructure layer remains separately deployable to Azure/AKS.

## Automated security self-test

`security/api-self-test.py` checks only the project's declared local endpoints. It verifies health responses and ensures sensitive-looking paths such as `.env`, `config.json` and `/admin` are not unexpectedly exposed.

The GitHub workflow starts the local Compose stack automatically, waits for the services, executes the self-test and checks the controlled Security Radar ghost route. Failures collect container logs before teardown.

## Kubernetes

The `k8s/` directory contains the namespace, application deployments, services, HPA, NetworkPolicies, probes, Gateway API routes and Workload Identity ServiceAccount configuration.

The NetworkPolicies use default-deny behavior for the protected workloads and explicitly permit required DNS egress. This reduces uncontrolled outbound communication while preserving cluster name resolution.

## Azure IaC

Terraform is modularized into networking, ACR, AKS and IAM/Workload Identity. The AKS configuration enables OIDC and Workload Identity and explicitly uses Azure CNI Overlay with Azure Network Policy. The networking mode is documented as an environment-specific trade-off rather than a universal best practice.

Bicep remains available as a second IaC representation.

The repository does not claim that Azure resources are deployed merely because the configuration exists. Deployment may create billable resources.

## CI / DevSecOps

GitHub Actions includes:

1. .NET restore, build and tests
2. Frontend install, lint and build
3. Kubernetes manifest validation
4. Bicep compilation
5. Terraform format and validation
6. Docker builds for application containers
7. Trivy vulnerability scanning
8. CycloneDX SBOM generation
9. CodeQL analysis
10. Checkov infrastructure security checks
11. Automated local API security self-testing
12. Scheduled health/security checks on the dedicated tool repositories

## Security

- Non-root runtime containers
- `runAsNonRoot`
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- Capabilities dropped with `ALL`
- Restricted Pod Security labels
- NetworkPolicy isolation
- OIDC / Workload Identity
- Managed identity access to ACR
- CodeQL and Dependabot
- Trivy image scanning and SBOM generation
- Controlled deception/self-test paths

No credentials, production data or patient information are included.

## Day-2 operations

See [`docs/observability-runbook.md`](docs/observability-runbook.md) for a concrete diagnostic path from Gateway and routing through NetworkPolicy, pod health, application logs and OpenTelemetry.

The repository also includes `k8s-pod-doctor` as a standalone operations tool for first-line diagnosis of common pod failures such as `CrashLoopBackOff` and `OOMKilled`.

## Production considerations

See [`docs/production-considerations.md`](docs/production-considerations.md) for cost, networking, observability and delivery trade-offs. The repository intentionally distinguishes architecture/configuration from runtime evidence.

## Resilience

`.github/workflows/chaos.yml` provides an explicitly triggered resilience test that authenticates to AKS using OIDC, deletes one selected pod and verifies that Kubernetes reconciliation restores the Deployment to its desired state. It does not claim an SLA or run destructive tests automatically.

## Verification discipline

Configuration in GitHub is not treated as proof of runtime behavior. Runtime claims require successful environment-specific verification, including deployment, HTTPS/TLS, telemetry ingestion, GitOps synchronization and recovery tests.

## Portfolio tools

The adjacent repositories extend the engineering lifecycle:

- `git-secrets-sentinel` — local shift-left secret detection
- `cloud-waste-auditor` — Terraform/FinOps cost-risk guardrail
- `k8s-pod-doctor` — Kubernetes Day-2 first-line diagnosis

## Scope

This is a portfolio showcase, not a production healthcare or community-management system. The application modules are intentionally small demonstrations of service boundaries, containers, Kubernetes and Azure platform engineering.

## Repository

https://github.com/abla86/azure-kubernetes-showcase
