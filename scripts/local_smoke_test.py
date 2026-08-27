import json
import subprocess
import sys
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

SERVICES = {
    "care-portal": "http://127.0.0.1:5001/health",
    "community-hub": "http://127.0.0.1:5002/health",
    "security-radar": "http://127.0.0.1:5080/health",
}

RADAR = "http://127.0.0.1:5080"


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


def main() -> int:
    print("Starting local smoke test...")

    try:
        result = subprocess.run(
            ["docker", "compose", "up", "-d", "--build"],
            check=False,
        )
        if result.returncode != 0:
            return result.returncode

        deadline = time.time() + 60
        while time.time() < deadline:
            try:
                results = {
                    name: request(url)[0]
                    for name, url in SERVICES.items()
                }
                if all(status == 200 for status in results.values()):
                    break
            except RuntimeError:
                pass
            time.sleep(2)
        else:
            print("Smoke test failed: one or more services did not become healthy.")
            return 1

        status_code, payload = request(f"{RADAR}/api/status")
        if status_code != 200:
            print(
                f"Smoke test failed: Security Radar status returned HTTP {status_code}."
            )
            return 1

        status = json.loads(payload)
        required_flags = (
            "controlledSimulation",
            "ghostRoute",
            "rateLimiting",
            "structuredSecurityEvents",
            "localEventFeed",
        )
        missing = [flag for flag in required_flags if status.get(flag) is not True]
        if missing:
            print(
                "Smoke test failed: missing Security Radar flags: "
                + ", ".join(missing)
            )
            return 1

        # First deception request: expected controlled 404.
        status_code, body = request(f"{RADAR}/ghost/smoke")
        if status_code != 404:
            print(f"Smoke test failed: first ghost request returned HTTP {status_code}.")
            return 1
        ghost = json.loads(body)
        if ghost.get("detected") is not True or ghost.get("deception") is not True:
            print("Smoke test failed: ghost route contract was not satisfied.")
            return 1

        # Second deception request: still inside the configured rate limit.
        status_code, _ = request(f"{RADAR}/ghost/smoke-2")
        if status_code != 404:
            print(f"Smoke test failed: second ghost request returned HTTP {status_code}.")
            return 1

        # Third deception request: must be rejected by the DeceptionWall limiter.
        status_code, _ = request(f"{RADAR}/ghost/smoke-3")
        if status_code != 429:
            print(
                "Smoke test failed: rate limiter expected HTTP 429 on third "
                f"deception request, got {status_code}."
            )
            return 1

        status_code, events_payload = request(f"{RADAR}/api/events")
        if status_code != 200:
            print(f"Smoke test failed: event feed returned HTTP {status_code}.")
            return 1
        events = json.loads(events_payload)
        actions = {event.get("action") for event in events}
        if "ghost-route-rejected" not in actions:
            print("Smoke test failed: expected ghost-route event not found.")
            return 1

        print("Local smoke test passed.")
        return 0
    finally:
        subprocess.run(["docker", "compose", "down", "-v"], check=False)


if __name__ == "__main__":
    sys.exit(main())
