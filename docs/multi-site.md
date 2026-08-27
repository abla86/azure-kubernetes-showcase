# Multi-site / multi-house model

The application can be extended from one household to many logical sites.

## Example logical topology

| Site | Purpose | Data boundary |
|---|---|---|
| house-01 | Demonstration household | isolated site identifier |
| house-02 | Demonstration household | isolated site identifier |
| house-03 | Demonstration household | isolated site identifier |

These are synthetic identifiers only.

## Recommended application model

Use stable IDs rather than addresses:

- Tenant / organization
- Site
- Device
- Event

A request should always carry the authenticated tenant/site context. Authorization must be enforced server-side; a client-supplied site ID must never be treated as proof of access.

## Scaling beyond one house

For a larger deployment, separate the logical concerns:

1. Identity and tenant authorization
2. Site/device registration
3. Telemetry ingestion
4. Event processing
5. API/query layer
6. Observability
7. Infrastructure lifecycle

This keeps the showcase extensible without pretending that the current repository already implements all of those production capabilities.
