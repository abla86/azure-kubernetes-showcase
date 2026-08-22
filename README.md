# Azure Kubernetes Showcase

A focused cloud-engineering portfolio project demonstrating a small full-stack application built with **ASP.NET Core/.NET 10, React/TypeScript, Docker and Kubernetes**, with Azure Infrastructure as Code and DevSecOps practices.

## What this demonstrates

- **Backend:** ASP.NET Core / .NET 10 REST API
- **Frontend:** React + TypeScript + Vite
- **Containers:** Multi-stage Docker builds; non-root web container
- **Kubernetes:** Deployment, Service, HPA, NetworkPolicy and Pod Security enforcement
- **Azure IaC:** Bicep and Terraform examples for Azure resources
- **CI:** GitHub Actions for .NET build/test, frontend lint/build, Docker builds and Kubernetes validation
- **Security:** CodeQL, Dependabot, restricted Kubernetes security context
- **Observability:** Serilog request logging, OpenTelemetry instrumentation and health checks

> **Verification status:** The repository contains deployment-ready examples, but this README does **not** claim that Azure/AKS has been deployed or that production infrastructure has been verified. CI status is the source of truth for automated verification.

## Architecture

```text
React + TypeScript
        |
        v
Nginx container
        |
        v
ASP.NET Core / .NET 10 API
        |
        +--> REST endpoints
        +--> Health checks
        +--> Serilog
        +--> OpenTelemetry
        |
        v
Docker
        |
        v
Kubernetes
        |
        +--> Deployment + Service
        +--> HPA
        +--> NetworkPolicy
        |
        v
Azure IaC examples
(Bicep / Terraform)
```

## API endpoints

| Endpoint | Purpose |
|---|---|
| `/health` | Kubernetes/container health check |
| `/api/health` | Application health information |
| `/api/info` | Runtime and application information |
| `/api/metrics` | Example application status metrics |
| `/api/events` | Example system events |

## Local development

### Prerequisites

- .NET 10 SDK
- Node.js 22+
- Docker Desktop
- kubectl (for Kubernetes validation/testing)

### Run the API

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release
```

### Run the frontend

```powershell
cd src/Web
npm ci
npm run lint
npm run build
```

### Run the complete application with Docker Compose

```powershell
docker compose up --build
```

Then open:

- Frontend: `http://localhost:5173`
- API: `http://localhost:5080`
- API health: `http://localhost:5080/health`

The production-style frontend container listens on port `8080` and proxies `/api/*` to the Compose API service.

## Kubernetes

The `k8s/` directory contains:

- API Deployment and ClusterIP Service
- Frontend Deployment and LoadBalancer Service
- Horizontal Pod Autoscaler
- NetworkPolicy
- Restricted Pod Security enforcement
- Readiness and liveness probes

Validate the manifests locally with:

```powershell
kubectl apply --dry-run=client -f k8s/
```

Container images must be available to the target cluster before a real deployment.

## Infrastructure as Code

Two Azure IaC examples are included:

- `infra/bicep/main.bicep`
- `infra/terraform/main.tf`

They intentionally remain small and auditable. They demonstrate Azure resource provisioning without falsely implying that the resources have already been deployed.

## CI and DevSecOps

GitHub Actions currently verifies:

1. .NET restore and Release build
2. .NET test suite with coverage collection
3. Frontend dependency installation, lint and production build
4. Kubernetes manifest validation
5. API and frontend Docker image builds
6. CodeQL analysis for C# and JavaScript/TypeScript

Dependabot monitors NuGet, npm, Docker and GitHub Actions dependencies.

## Testing

The repository includes ASP.NET Core integration-style endpoint tests using `WebApplicationFactory` for the health, info and metrics endpoints.

The project does **not** claim frontend E2E coverage or a production deployment until those have actually been implemented and verified.

## Security

Implemented controls include:

- Non-root frontend container
- Kubernetes `runAsNonRoot`
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- Linux capabilities dropped with `drop: ALL`
- Kubernetes restricted Pod Security enforcement
- NetworkPolicy for API ingress/DNS egress
- CodeQL security analysis
- Dependabot dependency monitoring

No credentials, production data or patient information are included.

## Scope

This is a **portfolio showcase**, not a production healthcare system. The purpose is to demonstrate practical full-stack, container, Kubernetes, Azure IaC and DevSecOps engineering skills in a small, auditable project.
