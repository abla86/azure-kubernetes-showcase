# IaC Parity Exceptions

## Purpose

Terraform and Bicep intentionally describe the same core Azure architecture, but they are not required to be byte-for-byte identical. Differences are recorded here rather than being presented as verified parity.

## Current documented exception

### Application Insights

- Terraform: provisions an `azurerm_application_insights` resource and passes its resource ID into the IAM module.
- Bicep: the current `infra/bicep/main.bicep` provisions Log Analytics but does not provision an Application Insights resource.

### Decision

This is a deliberate, documented parity exception. The Bicep path is not claimed to provide the same Application Insights resource as the Terraform path until an equivalent Bicep implementation is added and validated.

### Consequence

The project can use either IaC path for the demonstrated core platform, but documentation must not claim complete Terraform/Bicep parity for Application Insights.

### Verification state

- Architecture difference: verified from repository source.
- Live Azure equivalence: not verified in a deployed environment.
