# Architecture

## Target topology

The showcase is designed around a multi-site / multi-house scenario without requiring real household data.

```
Internet / users
       |
   Azure ingress
       |
   AKS cluster
   +-----------+
   | web pods  |
   +-----+-----+
         |
   +-----v-----+
   | API pods  |
   +-----+-----+
         |
   +-----v----------------+
   | Azure managed services|
   | ACR | Log Analytics   |
   +-----------------------+

Site A / House 01 ----\
Site B / House 02 ----- API / event boundary
Site C / House 03 ----/
```

Each house/site is a logical tenant boundary in the application model. No real addresses, credentials, telemetry or patient information are stored.

## Network model

- Public traffic terminates at the ingress/load-balancer boundary.
- Web workloads expose the user-facing service.
- API workloads are ClusterIP-only and accept traffic from the web workload through NetworkPolicy.
- Kubernetes DNS is explicitly allowed for API egress.
- Azure CNI/network policy is enabled in the AKS IaC example.
- Workload Identity/OIDC is enabled so workloads can use Azure identity without embedding client secrets.

## Scaling model

The API starts with two replicas and an HPA target of 70% CPU, with a maximum of five replicas. The values are demonstration defaults, not production capacity claims.

## Production boundary

This repository demonstrates architecture and deployable IaC patterns. Azure resources are not claimed to be deployed unless a deployment is explicitly verified.
