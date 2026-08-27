# Local stack

Run the complete application layer locally:

```bash
docker compose up --build
```

Services:

| Service | Local URL | Purpose |
|---|---|---|
| Security Radar | http://localhost:5080 | Controlled security/operations dashboard |
| CarePortal | http://localhost:5001 | Care and relative workflow API |
| CommunityHub | http://localhost:5002 | Community resource API |

The compose stack uses a dedicated bridge network named `showcase-net`.

The Security Radar's attack button is a **controlled simulation endpoint**. It does not perform a real attack, enumerate systems, collect IP addresses, or claim to be a SIEM. The simulated event is intended to demonstrate application-level detection and controlled delay behavior.

For Kubernetes, the corresponding security controls and telemetry are defined separately under `k8s/` and `infra/`.
