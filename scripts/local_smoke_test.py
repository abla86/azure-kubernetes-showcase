import json
import subprocess
import sys
import time
from dataclasses import dataclass
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

SERVICES = {
    "main-api": "http://127.0.0.1:5000/api/health",
    "web": "http://127.0.0.1:8080/",
    "care-portal": "http://127.0.0.1:5001/health",
    "community-hub": "http://127.0.0.1:5002/health",
    "security-radar": "http://127.0.0.1:5080/health",
}

RADAR = "http://127.0.0.1:5080"


@dataclass(frozen=True)
class TestResult:
    name: str
    passed: bool
    detail: str


def request(url: str, method: str = "GET") -> tuple[int, str]:
    req = Request(
        url,
        method=method,
        headers={"User-Agent": "showcase-smoke-test/1.0"},
    )
    try:
        with urlopen(req, timeout=5) as response:
            return response.status, response.read().decode("utf-8", errors="replace")
    except HTTPError as exc:
        return exc.code, exc.read().decode("utf-8", errors="replace")
    except URLError as exc:
        raise RuntimeError(f"Unable to reach {url}: {exc.reason}") from exc


def expect(test_name: str, condition: bool, detail: str) -> TestResult:
    result = TestResult(test_name, condition, detail)
    marker = "PASS" if result.passed else "FAIL"
    print(f"[{marker}] {result.name}: {result.detail}")
    return result


def main() -> int:
    print("Starting local smoke test...")
    results: list[TestResult] = []
    compose_started = False

    try:
        result = subprocess.run(
            ["docker", "compose", "up", "-d", "--build"],
            check=False,
        )
        compose_started = True
        results.append(
            expect(
                "compose-start",
                result.returncode == 0,
                f"docker compose exit={result.returncode}",
            )
        )
        if result.returncode != 0:
            return 1

        deadline = time.time() + 60
        last_statuses: dict[str, int | str] = {}
        while time.time() < deadline:
            try:
                last_statuses = {
                    name: request(url)[0]
                    for name, url in SERVICES.items()
                }
                if all(status == 200 for status in last_statuses.values()):
                    break
            except RuntimeError as exc:
                last_statuses = {"connection": str(exc)}
            time.sleep(2)
        else:
            results.append(
                expect(
                    "service-health",
                    False,
                    f"services did not become healthy: {last_statuses}",
                )
            )
            return 1

        results.append(
            expect(
                "service-health",
                True,
                "all local services returned HTTP 200",
            )
        )

        status_code, api_payload = request("http://127.0.0.1:5000/api/health")
        try:
            api_health = json.loads(api_payload)
        except json.JSONDecodeError:
            api_health = {}
        results.append(
            expect(
                "main-api-contract",
                status_code == 200 and api_health.get("status") == "healthy",
                "main API health contract is valid" if status_code == 200 and api_health.get("status") == "healthy" else f"HTTP {status_code} or invalid payload",
            )
        )

        status_code, payload = request(f"{RADAR}/api/status")
        if status_code != 200:
            results.append(
                expect(
                    "security-radar-status",
                    False,
                    f"HTTP {status_code}",
                )
            )
            return 1

        try:
            status = json.loads(payload)
        except json.JSONDecodeError as exc:
            results.append(
                expect(
                    "security-radar-status-json",
                    False,
                    f"invalid JSON: {exc}",
                )
            )
            return 1

        required_flags = (
            "controlledSimulation",
            "ghostRoute",
            "rateLimiting",
            "structuredSecurityEvents",
            "localEventFeed",
        )
        missing = [flag for flag in required_flags if status.get(flag) is not True]
        results.append(
            expect(
                "security-radar-capabilities",
                not missing,
                "all required flags enabled" if not missing else f"missing: {', '.join(missing)}",
            )
        )
        if missing:
            return 1

        status_code, body = request(f"{RADAR}/ghost/smoke")
        results.append(
            expect(
                "ghost-route-1",
                status_code == 404,
                f"expected HTTP 404, got {status_code}",
            )
        )
        if status_code != 404:
            return 1

        try:
            ghost = json.loads(body)
        except json.JSONDecodeError:
            ghost = {}
        valid_ghost = ghost.get("detected") is True and ghost.get("deception") is True
        results.append(
            expect(
                "ghost-route-contract",
                valid_ghost,
                "detected=true and deception=true" if valid_ghost else "response contract mismatch",
            )
        )
        if not valid_ghost:
            return 1

        status_code, _ = request(f"{RADAR}/ghost/smoke-2")
        results.append(
            expect(
                "ghost-route-2",
                status_code == 404,
                f"expected HTTP 404, got {status_code}",
            )
        )
        if status_code != 404:
            return 1

        status_code, _ = request(f"{RADAR}/ghost/smoke-3")
        results.append(
            expect(
                "deception-rate-limit",
                status_code == 429,
                f"expected HTTP 429 on third request, got {status_code}",
            )
        )
        if status_code != 429:
            return 1

        status_code, events_payload = request(f"{RADAR}/api/events")
        if status_code != 200:
            results.append(
                expect(
                    "security-event-feed",
                    False,
                    f"HTTP {status_code}",
                )
            )
            return 1

        try:
            events = json.loads(events_payload)
        except json.JSONDecodeError as exc:
            results.append(
                expect(
                    "security-event-feed-json",
                    False,
                    f"invalid JSON: {exc}",
                )
            )
            return 1

        actions = {event.get("action") for event in events if isinstance(event, dict)}
        results.append(
            expect(
                "security-event-feed",
                "ghost-route-rejected" in actions,
                "ghost-route-rejected event present" if "ghost-route-rejected" in actions else "expected event not found",
            )
        )

        passed = sum(result.passed for result in results)
        print(f"Smoke test summary: {passed}/{len(results)} checks passed.")
        if passed != len(results):
            print("Smoke test failed: at least one required test failed.")
            return 1

        print("Local smoke test passed.")
        return 0
    finally:
        if compose_started:
            subprocess.run(["docker", "compose", "down", "-v"], check=False)


if __name__ == "__main__":
    sys.exit(main())
