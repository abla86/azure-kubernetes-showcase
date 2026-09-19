# Cloud Waste Auditor

A lightweight FinOps guardrail for Terraform projects.

## What it does

Cloud Waste Auditor scans Terraform source files for explicitly configured Azure VM instance types that are often large enough to deserve a deliberate cost review.

It does **not** claim that a large instance is automatically wasteful.

## Features

- Recursive Terraform scanning
- Ignores `.git` and `.terraform`
- Reports file and line number
- Configurable high-cost instance patterns
- Non-zero exit code when findings are present
- Suitable for local use and CI

## Usage

```powershell
python auditor.py
```

## Example

```text
FINOPS WARNING: infra/main.tf:42: Standard_D32 requires cost review.

Audit complete: 3 Terraform file(s), 1 finding(s).
These are review flags, not proof of waste.
Consider workload requirements, environment, autoscaling and actual cost data.
```

## Why this exists

Infrastructure-as-code makes resource decisions visible before deployment. A small policy guardrail can force an explicit review of non-production capacity before a potentially expensive configuration reaches the cloud.

## Limitations

Static instance-type detection is only one part of FinOps. A proper decision should also consider utilization, workload performance, availability, autoscaling, Azure pricing, reservations/savings plans, data transfer and business requirements.

This tool is a static review aid, not a cloud billing calculator.

## License

MIT

## Change-control audit

See `docs/REPOSITORY-CHANGE-AUDIT-2026-08-28.md` for change-control and traceability rules.
