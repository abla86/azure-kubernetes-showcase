# Azure Kubernetes Showcase

A focused cloud-engineering portfolio project demonstrating a small full-stack application packaged for containers and prepared for Kubernetes/Azure deployment.

## What this project demonstrates

- ASP.NET Core / .NET 10 REST API
- React + TypeScript frontend
- Docker multi-stage builds
- Kubernetes Deployment, Service and HPA manifests
- Kubernetes restricted pod security settings
- Bicep and Terraform infrastructure examples
- GitHub Actions CI
- CodeQL analysis
- Dependabot configuration
- OpenTelemetry tracing/metrics integration
- Serilog structured application logging
- Health endpoint suitable for container/Kubernetes probes

## Architecture

```text
React + TypeScript
        |
        v
ASP.NET Core / .NET 10
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
        v
Azure (deployment-ready manifests/IaC)
```

## API endpoints

| Endpoint | Purpose |
|---|---|
| `/health` | Health check for container/Kubernetes probes |
| `/api/health` | Application health information |
| `/api/info` | Runtime and application information |
| `/api/metrics` | Simple application metrics/status information |
| `/api/events` | Example system events |

## Local development

### API

```powershell
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release
```

### Frontend

```powershell
cd src/Web
npm ci
npm run lint
npm run build
```

### Docker Compose

```powershell
docker compose up --build
```

The API is exposed on `http://localhost:5080` and the frontend on `http://localhost:5173` when using the supplied Compose configuration.

## Kubernetes

The `k8s/` directory contains:

- API Deployment and Service
- Frontend Deployment and Service
- Horizontal Pod Autoscaler
- NetworkPolicy

The manifests are intended to be validated before deployment to a cluster. Container images must exist in a registry accessible by the target cluster before an actual remote deployment.

## Infrastructure as Code

The repository contains examples for both:

- `infra/bicep/main.bicep`
- `infra/terraform/main.tf`

The current IaC files deliberately remain small and auditable. They demonstrate Azure resource provisioning without claiming that the resources have been deployed when they have not.

## CI/CD and security

GitHub Actions performs:

1. .NET restore, build and test
2. Frontend dependency installation, lint and build
3. API and frontend Docker image builds
4. CodeQL analysis for C#

Dependabot is configured for npm, Docker and GitHub Actions dependencies.

## Verification status

This repository distinguishes between configuration present in source control and infrastructure that has actually been deployed. Azure/Kubernetes deployment is not described as production deployment unless a real deployment and verification have succeeded.

## Project scope

This is a portfolio showcase rather than a production healthcare system. It contains no production data, credentials or real patient information.
