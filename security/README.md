# Security self-tests

The repository contains automated defensive checks for its own local services and Kubernetes configuration.

## Automated checks

- `api-self-test.py` checks expected health endpoints and verifies that common sensitive/admin paths are not unintentionally exposed.
- `security-self-test.yml` builds and starts the local Compose stack, executes the API self-test, verifies the controlled deception route, collects logs on failure, and tears the stack down.
- Kubernetes policy files use explicit ingress and DNS-only egress rules where required.

## Scope

All HTTP self-tests target loopback addresses owned by this project. They are designed for validation of the project's own services, not for scanning third-party systems.

## Deliberately redacted details

The tests use generic classifications such as `sensitive-path` and `admin-path` rather than publishing a large operational wordlist. This keeps the security intent visible without turning the repository into a ready-made directory enumeration list.
