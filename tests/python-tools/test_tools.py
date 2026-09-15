import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


DOCTOR = load_module("doctor", ROOT / "tools/k8s-pod-doctor/doctor.py")
AUDITOR = load_module("auditor", ROOT / "tools/cloud-waste-auditor/auditor.py")


class PodDoctorTests(unittest.TestCase):
    def test_detects_generic_waiting_reason(self):
        pod = {
            "metadata": {"namespace": "demo", "name": "api"},
            "status": {"containerStatuses": [{
                "name": "api",
                "ready": False,
                "state": {"waiting": {"reason": "ImagePullBackOff"}},
            }]},
        }
        findings = DOCTOR.diagnose_pod(pod)
        self.assertEqual(["ImagePullBackOff"], [item["reason"] for item in findings])

    def test_detects_current_and_previous_oom(self):
        pod = {
            "metadata": {"namespace": "demo", "name": "worker"},
            "status": {"containerStatuses": [{
                "name": "worker",
                "state": {"terminated": {"reason": "OOMKilled"}},
                "lastState": {"terminated": {"reason": "OOMKilled"}},
            }]},
        }
        reasons = [item["reason"] for item in DOCTOR.diagnose_pod(pod)]
        self.assertEqual(["OOMKilled", "Previous OOMKilled"], reasons)


class CloudWasteAuditorTests(unittest.TestCase):
    def test_custom_instance_pattern_is_supported(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "main.tf"
            path.write_text('vm_size = "Standard_X99"\n', encoding="utf-8")
            self.assertEqual([("Standard_X99", 1)], AUDITOR.audit_file(path, {"Standard_X99"}))

    def test_terraform_file_discovery_excludes_state_directories(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "main.tf").write_text("resource {}", encoding="utf-8")
            (root / ".terraform").mkdir()
            (root / ".terraform" / "ignored.tf").write_text("ignored", encoding="utf-8")
            files = AUDITOR.terraform_files(root)
            self.assertEqual([root / "main.tf"], files)


if __name__ == "__main__":
    unittest.main()
