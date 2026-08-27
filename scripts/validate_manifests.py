from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
K8S_DIR = ROOT / "k8s"

REQUIRED_PROBES = ("startupProbe", "readinessProbe", "livenessProbe")
REQUIRED_DROP_CAP = "ALL"


def iter_documents() -> list[tuple[Path, dict[str, Any]]]:
    documents: list[tuple[Path, dict[str, Any]]] = []
    for path in K8S_DIR.rglob("*.y*ml"):
        try:
            for document in yaml.safe_load_all(path.read_text(encoding="utf-8")):
                if isinstance(document, dict):
                    documents.append((path, document))
        except (OSError, yaml.YAMLError) as exc:
            raise RuntimeError(f"Cannot parse {path}: {exc}") from exc
    return documents


def validate() -> int:
    errors: list[str] = []

    if not K8S_DIR.exists():
        print(f"ERROR: Kubernetes directory not found: {K8S_DIR}")
        return 1

    for path, document in iter_documents():
        if document.get("kind") != "Deployment":
            continue

        name = document.get("metadata", {}).get("name", "unknown")
        pod_spec = document.get("spec", {}).get("template", {}).get("spec", {})
        pod_security = pod_spec.get("securityContext", {}) or {}

        seccomp = pod_security.get("seccompProfile", {}) or {}
        if seccomp.get("type") != "RuntimeDefault":
            errors.append(f"{path}: Deployment/{name} missing pod seccompProfile RuntimeDefault")

        for container in pod_spec.get("containers", []) or []:
            container_name = container.get("name", "unknown")
            prefix = f"{path}: Deployment/{name} container/{container_name}"
            security = container.get("securityContext", {}) or {}

            if security.get("runAsNonRoot") is not True:
                errors.append(f"{prefix} missing runAsNonRoot: true")
            if security.get("allowPrivilegeEscalation") is not False:
                errors.append(f"{prefix} missing allowPrivilegeEscalation: false")
            if security.get("readOnlyRootFilesystem") is not True:
                errors.append(f"{prefix} missing readOnlyRootFilesystem: true")

            dropped = set((security.get("capabilities", {}) or {}).get("drop", []) or [])
            if REQUIRED_DROP_CAP not in dropped:
                errors.append(f"{prefix} must drop ALL capabilities")

            for probe in REQUIRED_PROBES:
                if not isinstance(container.get(probe), dict):
                    errors.append(f"{prefix} missing {probe}")

    print(f"Kubernetes policy scan complete: {len(list(K8S_DIR.rglob('*.y*ml')))} YAML files inspected")
    if errors:
        print(f"POLICY VIOLATIONS: {len(errors)}")
        for error in errors:
            print(f" - {error}")
        return 1

    print("Kubernetes security policy: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(validate())
