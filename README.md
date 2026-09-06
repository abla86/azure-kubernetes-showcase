# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)

A cloud-engineering portfolio project demonstrating .NET 10, React/TypeScript, Docker, Kubernetes, Azure IaC and DevSecOps, with deliberately small application services and controlled resilience/security checks.

## Fast evaluation

**Test the application layer locally:**

```powershell
docker compose up --build
```

Then open Security Radar at `http://localhost:5080`, Care Portal at `http://localhost:5001` and Community Hub at `http://localhost:5002`.

**Canonical local verification:**

```powershell
python scripts/local_smoke_test.py
```

The smoke test starts the Compose stack, waits for service health, verifies Security Radar capabilities, exercises the controlled ghost route and rate limiter, validates the local security-event feed, and always tears the stack down afterwards.

## What it demonstrates

- ASP.NET Core / .NET 10 APIs
- React + TypeScript + Vite
- Core Showcase API, Care Portal and Community Hub modules
- Multi-stage non-root Docker containers
- Kubernetes Deployments, Services, startup/readiness/liveness probes, HPA and NetworkPolicy
- Restricted Pod Security
- Azure Bicep and modular Terraform
- AKS OIDC / Workload Identity
- ACR pull permissions
- GitHub Actions CI/CD
- CodeQL, Dependabot, Trivy and SBOM generation
- OpenTelemetry with optional local collector and Azure Monitor integration
- Security Radar for controlled security-event simulation
- Automated local API security self-tests
- Controlled Kubernetes resilience testing
- IaC parity checks and repository-maintenance automation

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
  |   +--------------> Checkov / Kubeconform / policy
  +------------------> Build / Test / Smoke
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

A controlled operations/security demonstration with a local event feed, bounded-delay simulation endpoint, rate limiting and application-level ghost route. It does not claim to be a production SIEM or intrusion-detection platform.

## Local development

Prerequisites: .NET 10 SDK, Node.js 22+, Docker Desktop, kubectl and optionally Azure CLI/Terraform.

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release
python scripts/local_smoke_test.py
```

The local Compose stack contains the application services used for the defensive self-test plus Security Radar. The infrastructure layer remains separately deployable to Azure/AKS.

## Automated security self-test

`security/api-self-test.py` checks only the project's declared local endpoints. It verifies health responses and ensures sensitive-looking paths such as `.env`, `config.json` and `/admin` are not unexpectedly exposed.

`scripts/local_smoke_test.py` is the canonical integration smoke test. It fails on missing or incorrect required behavior and returns a non-zero exit code when any required assertion fails.

The main CI workflow runs the same smoke test automatically on pushes, pull requests and manual dispatch. Failed Compose runs collect Docker diagnostics.

## Kubernetes

The `k8s/` directory contains the namespace, application deployments, services, HPA, NetworkPolicies, probes, Gateway API routes and Workload Identity ServiceAccount configuration.

The NetworkPolicies use default-deny behavior for the protected workloads and explicitly permit required DNS egress. This reduces uncontrolled outbound communication while preserving cluster name resolution.

`scripts/validate_manifests.py` enforces the required workload controls, including non-root execution, no privilege escalation, read-only root filesystems, dropped capabilities, seccomp and startup/readiness/liveness probes.

## Azure IaC

Terraform is modularized into networking, ACR, AKS and IAM/Workload Identity. The AKS configuration enables OIDC and Workload Identity and explicitly uses Azure CNI Overlay with Azure Network Policy.

Bicep remains available as a second IaC representation. CI compiles all Bicep files and validates Terraform formatting and configuration without requiring an Azure deployment.

The repository does not claim that Azure resources are deployed merely because the configuration exists. Deployment may create billable resources.

### IaC parity

See [`docs/iac-parity-matrix.md`](docs/iac-parity-matrix.md) and [`docs/iac-parity-exceptions.md`](docs/iac-parity-exceptions.md). Differences are documented explicitly rather than being marked as accidental drift.

## Cost controls

Terraform includes a configurable resource-group budget guardrail. Budget thresholds and notification recipients are variables rather than hardcoded secrets. The repository does not automatically optimize cloud spend; it makes the cost boundaries visible.

The local cost audit is self-contained and does not require a sibling checkout.

## CI / DevSecOps

GitHub Actions includes:

1. .NET restore, build and tests
2. Frontend install, lint and build
3. Kubernetes manifest validation and workload security policy
4. Bicep compilation
5. Terraform format and validation
6. Docker builds for application containers
7. Trivy vulnerability scanning
8. CycloneDX SBOM generation
9. CodeQL analysis
10. Checkov infrastructure security checks
11. Kubeconform Kubernetes schema validation
12. IaC parity-contract checks
13. Automated local API security self-testing
14. Canonical local smoke testing of the Compose stack
15. Automated repository maintenance checks

Terraform planning is automatic; actual Terraform apply is explicitly opt-in through the deployment workflow.

## Security architecture — infrastructure and delivery

**Portfolio security focus:** supply-chain security, workload hardening, least privilege, identity, network boundaries and verified recovery.

CloudForge treats security as a set of controls across the software supply chain, container runtime, Kubernetes boundary and Azure identity layer.

| Layer | Control | What it demonstrates |
|---|---|---|
| Source | CodeQL, Dependabot | Static analysis and dependency monitoring |
| Build | Trivy, SBOM, Checkov | Image, dependency and IaC supply-chain checks |
| Kubernetes | Restricted Pod Security, non-root, seccomp, dropped capabilities | Workload hardening and least privilege |
| Network | Default-deny NetworkPolicies with explicit DNS egress | Explicit workload communication boundaries |
| Identity | OIDC / Workload Identity and ACR permissions | Short-lived workload identity instead of stored cloud credentials |
| Configuration | Kubeconform, policy validation and IaC parity checks | Preventing invalid or divergent infrastructure configuration |
| Runtime | OpenTelemetry and diagnostic runbook | Security-relevant observability and Day-2 diagnosis |
| Resilience | Controlled pod deletion and reconciliation test | Verifiable recovery behaviour rather than a resilience claim |

This is intentionally different from application-level security in HealthTech Platform: CloudForge demonstrates how security controls are embedded in delivery and infrastructure rather than primary application features.

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

See [`docs/production-considerations.md`](docs/production-considerations.md) for cost, networking, observability and delivery trade-offs. The repository intentionally distinguishes architecture choices from operational guarantees.

## Resilience

[`.github/workflows/chaos.yml`](.github/workflows/chaos.yml) provides an explicitly triggered resilience test that authenticates to AKS using OIDC, deletes one selected pod and verifies that Kubernetes reconciliation restores the workload.

## Verification discipline

Configuration in GitHub is not treated as proof of runtime behavior. Runtime claims require successful environment-specific verification, including deployment, HTTPS/TLS, telemetry ingestion, GitHub Actions and smoke tests.

When a required test or file is missing, the repository validation policy treats that as a failure rather than silently skipping it.

## Portfolio tools

The adjacent repositories extend the engineering lifecycle:

- `git-secrets-sentinel` — local shift-left secret detection
- `cloud-waste-auditor` — Terraform/FinOps cost-risk guardrail
- `k8s-pod-doctor` — Kubernetes Day-2 first-line diagnosis

## Automated maintenance

Repository maintenance runs on a schedule and manually. It validates required documentation, scans for unfinished placeholders, checks parity-exception records and creates a maintenance issue on failure instead of silently changing source code.

The repository also maintains a changelog and architecture log so engineering decisions and material changes remain traceable.

## Scope

This is a portfolio showcase, not a production healthcare or community-management system. The application modules are intentionally small demonstrations of service boundaries, containers, Kubernetes and Azure platform engineering.

## Repository

https://github.com/abla86/azure-kubernetes-showcase

## Change-control audit

See [docs/REPOSITORY-CHANGE-AUDIT-2026-08-28.md](docs/REPOSITORY-CHANGE-AUDIT-2026-08-28.md) for the repository change-control and traceability record.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.








## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.

## Automated repository metadata

See [generated repository snapshot](docs/generated/repository-snapshot.md) for the current repository head and tracked engineering areas.
