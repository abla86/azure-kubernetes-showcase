# Security

## Security principles

This project demonstrates:

- non-root containers
- dropped Linux capabilities
- Kubernetes security contexts
- NetworkPolicy
- CodeQL
- Dependabot
- Trivy
- GitHub Actions least privilege
- environment-based configuration
- no committed credentials

## Secrets

No real credentials belong in this repository.

Azure credentials must use GitHub Actions OIDC or GitHub Secrets.

## Limitations

This is a portfolio project.

It is not a production security certification.

A production deployment would additionally require:

- enterprise identity
- MFA
- formal threat modelling
- penetration testing
- managed secret storage
- network segmentation
- backup/recovery controls
- privacy assessment
