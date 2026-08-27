"""Controlled API self-test for the Azure Kubernetes Showcase.

The target base URL is intentionally restricted to local/private hosts so this
utility remains a test harness for services you control.
"""

from __future__ import annotations

import argparse
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from urllib.parse import urlparse

DEFAULT_TARGET = "http://localhost:5001"

WORDLIST = (
    ("ghost-route", "/api/v1/internal/legacy-db-dump", {404}),
    ("swagger", "/swagger/v1/swagger.json", {200, 401, 403, 404}),
    ("health", "/health", {200}),
    ("resource", "/api/resource", {200, 401, 403, 404}),
    ("admin", "/admin", {401, 403, 404}),
    ("environment-file", "/.env", {403, 404}),
    ("config-file", "/config.json", {403, 404}),
    ("metrics", "/metrics", {200, 401, 403, 404}),
)


@dataclass(frozen=True)
class CheckResult:
    name: str
    path: str
    status: int | None
    passed: bool
    detail: str


def validate_target(target: str) -> str:
    parsed = urlparse(target)

    if parsed.scheme not in {"http", "https"} or not parsed.hostname:
        raise ValueError("Target must be an absolute HTTP(S) URL.")

    allowed_hosts = {"localhost", "127.0.0.1", "::1"}
    if parsed.hostname not in allowed_hosts:
        raise ValueError(
            "This self-test only permits localhost targets "
            "(localhost, 127.0.0.1, ::1)."
        )

    return target.rstrip("/")


def request(target: str, path: str) -> tuple[int, str]:
    url = f"{target}{path}"
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "Showcase-SelfTest/1.0"},
        method="GET",
    )

    try:
        with urllib.request.urlopen(req, timeout=3) as response:
            body = response.read(4096).decode("utf-8", errors="replace")
            return response.status, body
    except urllib.error.HTTPError as exc:
        body = exc.read(4096).decode("utf-8", errors="replace")
        return exc.code, body


def run(target: str) -> list[CheckResult]:
    results: list[CheckResult] = []

    for name, path, expected in WORDLIST:
        try:
            status, body = request(target, path)
            passed = status in expected

            detail = f"HTTP {status}"

            if name == "ghost-route" and status == 404 and "legacy-db-dump" not in body:
                detail += "; decoy rejected"

            results.append(
                CheckResult(name, path, status, passed, detail)
            )
        except urllib.error.URLError as exc:
            results.append(
                CheckResult(name, path, None, False, f"connection error: {exc}")
            )

    return results


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run controlled security checks against a local showcase API."
    )
    parser.add_argument(
        "--target",
        default=DEFAULT_TARGET,
        help=f"Local target URL (default: {DEFAULT_TARGET})",
    )
    args = parser.parse_args()

    try:
        target = validate_target(args.target)
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 2

    print(f"Showcase API self-test: {target}")

    results = run(target)
    failures = 0

    for result in results:
        marker = "PASS" if result.passed else "FAIL"
        print(f"[{marker}] {result.name:18} {result.path:42} {result.detail}")
        if not result.passed:
            failures += 1

    print()
    print(
        f"Completed {len(results)} checks: "
        f"{len(results) - failures} passed, {failures} failed."
    )

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
