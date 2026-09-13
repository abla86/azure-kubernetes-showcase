import http.client
import sys
from urllib.parse import urlparse

TARGETS = {
    "care-portal": "http://127.0.0.1:5001",
    "community-hub": "http://127.0.0.1:5002",
    "security-radar": "http://127.0.0.1:5080",
}

PATHS = (
    ("/health", "health"),
    ("/.env", "sensitive-path"),
    ("/config.json", "sensitive-path"),
    ("/admin", "admin-path"),
)


def request(base_url, path):
    parsed = urlparse(base_url)
    conn = http.client.HTTPConnection(parsed.hostname, parsed.port, timeout=3)
    try:
        conn.request("GET", path, headers={"User-Agent": "Showcase-SelfTest/1.0"})
        response = conn.getresponse()
        body = response.read(4096).decode("utf-8", errors="replace")
        return response.status, body
    finally:
        conn.close()


def main():
    failures = 0

    for name, base_url in TARGETS.items():
        print(f"[{name}] {base_url}")

        for path, kind in PATHS:
            try:
                status, body = request(base_url, path)
            except OSError as exc:
                print(f"  ERROR {path}: {exc}")
                failures += 1
                continue

            if kind == "health":
                if status != 200:
                    print(f"  FAIL {path}: expected 200, got {status}")
                    failures += 1
                else:
                    print(f"  PASS {path}: 200")
            else:
                if status in (401, 403, 404):
                    print(f"  PASS {path}: protected/not exposed ({status})")
                else:
                    print(f"  FAIL {path}: unexpected exposure ({status})")
                    failures += 1

    if failures:
        print(f"\nSelf-test failed: {failures} check(s).")
        return 1

    print("\nAPI self-test passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
