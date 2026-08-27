# Changelog

All notable changes to this project are documented in this file.

The format follows the general structure of Keep a Changelog. Automated maintenance may append review entries, but release entries are kept human-reviewable.

## Unreleased

### Added
- Automated Kubernetes workload security validation.
- Automated local smoke testing for the Compose stack.
- Security Radar deception and rate-limit verification.
- Terraform cost budget guardrails.
- IaC parity documentation between Terraform and Bicep.

### Changed
- Terraform apply is explicitly opt-in instead of running on every infrastructure push.
- Local OpenTelemetry collector is opt-in.
- Container images use commit-based identifiers in deployment manifests.

### Verification status
- Local and CI configuration: implemented.
- GitHub Actions execution: requires successful workflow runs for empirical verification.
- Azure runtime capabilities: require an active Azure environment and are not claimed as live unless tested there.
