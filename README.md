# Azure Kubernetes Showcase

[![CI/CD](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/abla86/azure-kubernetes-showcase/actions/workflows/ci-cd.yml)
[![Azure IaC](https://img.shields.io/badge/Azure%20IaC-Bicep%20%2B%20Terraform-0078D4)](https://azure.microsoft.com/)
[![Security](https://img.shields.io/badge/security-CodeQL%20%2B%20Dependabot-blue)](https://github.com/abla86/azure-kubernetes-showcase/security)
[![.NET](https://img.shields.io/badge/.NET-10-512BD4)](https://dotnet.microsoft.com/)
[![React](https://img.shields.io/badge/React-TypeScript-61DAFB)](https://react.dev/)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Deployment-326CE5)](https://kubernetes.io/)

A focused cloud-engineering portfolio project demonstrating a small full-stack application built with **ASP.NET Core/.NET 10, React/TypeScript, Docker and Kubernetes**, with Azure Infrastructure as Code and DevSecOps practices.

## Portfolio snapshot

This repository is designed as an employer-facing engineering showcase. It demonstrates:

- **Backend:** ASP.NET Core / .NET 10 REST API
- **Frontend:** React + TypeScript + Vite
- **Containers:** Multi-stage Docker builds with non-root runtime users
- **Kubernetes:** Deployments, Services, HPA, NetworkPolicy, probes and restricted Pod Security
- **Azure IaC:** Bicep and Terraform examples
- **CI/CD:** GitHub Actions for build, test, lint, Docker and Kubernetes validation
- **Security:** CodeQL, Dependabot and least-privilege Kubernetes security controls
- **Observability:** Serilog request logging, OpenTelemetry instrumentation and health endpoints

## Current verification

The application has been run locally on Docker Desktop Kubernetes and verified with:

- API deployment: **2/2 Ready**
- Frontend deployment: **2/2 Ready**
- API health endpoint: **healthy**
- Kubernetes services: **available**
- API and frontend containers: **Running**

The CI pipeline also validates the repository's Azure Infrastructure as Code:

- Bicep compilation is checked automatically
- Terraform formatting and validation are checked automatically

This is a local Kubernetes verification plus automated IaC validation, not a claim that production Azure/AKS infrastructure has been deployed.

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
        +--> Restricted Pod Security
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
- Azure CLI (for optional local Bicep validation)
- Terraform 1.6+ (for optional local IaC validation)

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

The production-style frontend container listens on port `8080` and proxies `/api/*` to the API service.

## Kubernetes

The `k8s/` directory contains:

- API Deployment and ClusterIP Service
- Frontend Deployment and LoadBalancer Service
- Horizontal Pod Autoscaler
- NetworkPolicy
- Restricted Pod Security enforcement
- Readiness and liveness probes

Example local validation:

```powershell
kubectl apply --dry-run=client -f k8s/
```

For the Docker Desktop cluster used during local verification:

```powershell
kubectl apply -f k8s/
kubectl get deployments,pods,services -n showcase
```

## Azure Infrastructure as Code

Two small, auditable Azure IaC examples are included:

- `infra/bicep/main.bicep`
- `infra/terraform/main.tf`

GitHub Actions validates both representations on pushes and pull requests. The project deliberately demonstrates **Azure provisioning skills without claiming that Azure resources have already been deployed**.

For a local Bicep compilation check:

```powershell
az bicep build --file infra/bicep/main.bicep
```

For local Terraform validation:

```powershell
cd infra/terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## CI and DevSecOps

GitHub Actions is configured for:

1. .NET restore, Release build and tests
2. Frontend dependency installation, lint and production build
3. Kubernetes manifest validation
4. Azure Bicep compilation
5. Azure Terraform formatting and validation
6. API and frontend Docker image builds
7. CodeQL analysis for C# and JavaScript/TypeScript

Dependabot monitors NuGet, npm, Docker and GitHub Actions dependencies.

## Testing

The repository includes ASP.NET Core integration-style endpoint tests using `WebApplicationFactory` for the health, info and metrics endpoints.

The project does **not** claim frontend E2E coverage or a production Azure deployment unless those have actually been implemented and verified.

## Security

Implemented controls include:

- Non-root API and frontend containers
- Kubernetes `runAsNonRoot`
- Explicit non-root API UID
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

## Repository

**GitHub:** https://github.com/abla86/azure-kubernetes-showcase

The repository's `main` branch is the published version.
