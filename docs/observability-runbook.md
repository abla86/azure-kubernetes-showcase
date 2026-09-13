# Observability and Day-2 Troubleshooting

The intended troubleshooting path follows the request through the platform.

## Request path

Client -> Gateway/HTTPS -> HTTPRoute -> Kubernetes Service -> NetworkPolicy -> Pod -> ASP.NET Core -> OpenTelemetry -> Azure Monitor

## Diagnostic sequence

1. Gateway: verify the Gateway is accepted and its HTTPS listener has the expected address and certificate.
2. HTTPRoute: verify the route is attached and points to the expected Service.
3. Service: verify endpoints exist and point to ready pods.
4. NetworkPolicy: check whether the source workload is explicitly allowed to reach the destination.
5. Pod: inspect readiness/liveness, restart count, resource pressure and container logs.
6. Application: call the health endpoint and inspect structured logs.
7. Telemetry: confirm OpenTelemetry traces/metrics reach Azure Monitor when running in Azure with the required identity permissions.

## Controlled failure

The chaos workflow deletes one selected application pod and waits for the Deployment to recover. It demonstrates Kubernetes reconciliation; it does not establish an SLA.

## Security Radar

The ghost route is an application-level controlled deception demonstration. Its event feed is not a live Azure SIEM feed and does not prove NetworkPolicy enforcement.
