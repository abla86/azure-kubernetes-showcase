# Architecture Log

This log records notable architecture and engineering decisions for the showcase.

## 2026-08-27 — Local versus enterprise observability

- Local Compose runs without an external OpenTelemetry Collector by default.
- OTEL export is enabled explicitly with `OTEL_ENABLED=true`.
- Rationale: keep local development lightweight while preserving an enterprise telemetry path.

## 2026-08-27 — Controlled deception

- Deception routes are isolated from ordinary application routes.
- Deception traffic is rate-limited and emits structured security events.
- No automatic counterattack, credential callback, or external beacon is used.
- Rationale: demonstrate defensive security engineering without introducing unnecessary external side effects.

## 2026-08-27 — Infrastructure changes

- Terraform `apply` is opt-in and requires explicit manual execution.
- CI performs formatting, initialization, validation and planning before infrastructure changes.
- Rationale: infrastructure mutation should not occur as an accidental side effect of an ordinary code push.

## 2026-08-27 — IaC parity

- Terraform and Bicep are treated as alternative infrastructure implementations governed by a shared parity contract.
- Known intentional differences are documented instead of being marked as verified parity.
- Rationale: configuration similarity is not runtime equivalence.
