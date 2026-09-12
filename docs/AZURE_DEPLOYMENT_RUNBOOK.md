# Azure Deployment Runbook

This runbook is the shortest supported path from a clean checkout to a public Azure deployment.

## Prerequisites

- Azure subscription
- GitHub repository with Actions enabled
- Azure CLI
- Terraform
- `kubectl`
- Docker

## Identity

Use GitHub Actions OIDC with an Azure federated credential. Do not store an Azure client secret in GitHub.

Required GitHub configuration is documented by the deployment workflow. Keep production credentials and application secrets outside Git.

## Deployment

1. Create/configure the Azure resource group and Terraform state backend according to the repository IaC.
2. Configure the GitHub environment used by the production deployment.
3. Configure the Azure federated identity for the repository/branch or environment.
4. Set only the non-secret deployment variables required by Terraform and the application.
5. Run the infrastructure workflow with `plan` first.
6. Review the plan, then run `apply`.
7. Run the application deployment workflow.
8. Wait for rollout completion and run the repository smoke/self-tests against the resulting public endpoint.
9. Confirm HTTPS, health/readiness, API, frontend and observability endpoints.

## Verification gate

A deployment is **publicly verified** only when the deployed HTTPS endpoint responds successfully and the repository smoke tests pass against that endpoint. A successful Terraform apply alone is not sufficient.

## Cost control

Use the smallest supported Azure SKUs for the showcase. Destroy non-required environments when they are not being demonstrated. Do not add managed services unless the application actually requires them.

## Failure handling

If CI fails, inspect the failed job and fix the root cause before retrying. Do not bypass validation or mark a deployment successful from documentation alone.
