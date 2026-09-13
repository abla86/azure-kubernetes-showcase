# Production Considerations

This project is a technical showcase. These are deliberate trade-offs, not universal recommendations.

## Cost

AKS, Azure Container Registry, Application Insights/Log Analytics, networking and public ingress can all create billable Azure resources. Cloud deployment is therefore opt-in. A Terraform plan is not evidence of deployment.

For a real environment, estimate cost from the selected Azure region, AKS node VM size/count, storage, outbound traffic, registry tier, observability ingestion/retention and ingress architecture. Use the current Azure pricing calculator and actual workload profile rather than a hard-coded monthly estimate.

## Networking trade-offs

The design favors isolation and explicit policy over unrestricted pod-to-pod communication. Azure CNI/AKS networking mode should be selected against address-space requirements, scale, policy support, operational model and cost.

## Observability trade-off

OpenTelemetry provides vendor-neutral instrumentation while the Azure Monitor exporter aligns the showcase with Azure operations. Telemetry volume, sampling and retention must be controlled in production.

## Security trade-off

Default-deny NetworkPolicies and Restricted Pod Security reduce blast radius but increase configuration responsibility. New dependencies require explicit, tested communication paths.

## Delivery trade-off

GitHub OIDC removes long-lived Azure credentials from workflows. Terraform apply remains privileged and should use environment protection, approvals and least-privilege Azure RBAC in a real organization.

## What is not claimed

Repository configuration is not treated as production evidence. Production claims require successful environment-specific deployment, security validation, runtime tests, telemetry verification, TLS verification and operational ownership.
