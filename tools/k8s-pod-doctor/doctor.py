import json
import subprocess
import sys


def _finding(namespace, name, container, reason):
    return {"namespace": namespace, "name": name, "container": container, "reason": reason}


def diagnose_pod(pod):
    """Return structured findings for one Kubernetes pod."""
    namespace = pod.get("metadata", {}).get("namespace", "unknown")
    name = pod.get("metadata", {}).get("name", "unknown")
    findings = []

    for status in pod.get("status", {}).get("containerStatuses", []) or []:
        state = status.get("state", {}) or {}
        last_state = status.get("lastState", {}) or {}
        container = status.get("name", "unknown")

        waiting = state.get("waiting") or {}
        waiting_reason = waiting.get("reason")
        if waiting_reason:
            findings.append(_finding(namespace, name, container, waiting_reason))

        terminated = state.get("terminated") or {}
        if terminated.get("reason") == "OOMKilled":
            findings.append(_finding(namespace, name, container, "OOMKilled"))

        previous = last_state.get("terminated") or {}
        if previous.get("reason") == "OOMKilled":
            findings.append(_finding(namespace, name, container, "Previous OOMKilled"))

        if status.get("ready") is False and not waiting and not terminated:
            findings.append(_finding(namespace, name, container, "NotReady"))

    return findings


def get_unhealthy_pods():
    print("K8s Pod Doctor health check...")
    try:
        result = subprocess.run(
            ["kubectl", "get", "pods", "--all-namespaces", "-o", "json"],
            capture_output=True, text=True, check=True,
        )
        data = json.loads(result.stdout)
    except FileNotFoundError:
        print("ERROR: kubectl is not installed or not in PATH.")
        return 1
    except subprocess.CalledProcessError as exc:
        print("ERROR: Could not query Kubernetes.")
        print(exc.stderr.strip())
        return 1
    except json.JSONDecodeError:
        print("ERROR: kubectl returned invalid JSON.")
        return 1

    issues_found = False
    for pod in data.get("items", []):
        for finding in diagnose_pod(pod):
            issues_found = True
            prefix = "MEMORY" if "OOMKilled" in finding["reason"] else "ALERT"
            print(f"{prefix}: Pod {finding['namespace']}/{finding['name']} container {finding['container']} — {finding['reason']}.")

    if not issues_found:
        print("No configured unhealthy pod conditions detected.")
        return 0

    print("\nRecommendation: inspect the affected pod with 'kubectl describe pod' and 'kubectl logs'.")
    return 1


if __name__ == "__main__":
    sys.exit(get_unhealthy_pods())
