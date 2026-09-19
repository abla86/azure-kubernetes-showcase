import tempfile
import unittest
from pathlib import Path

from auditor import audit_file


class AuditorTests(unittest.TestCase):
    def make_file(self, content):
        handle = tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", delete=False)
        handle.write(content)
        handle.close()
        self.addCleanup(Path(handle.name).unlink)
        return Path(handle.name)

    def test_clean_terraform(self):
        path = self.make_file('vm_size = "Standard_D2s_v5"')
        self.assertEqual(audit_file(path), [])

    def test_detects_large_instance(self):
        path = self.make_file('vm_size = "Standard_D32"')
        findings = audit_file(path)
        self.assertEqual(findings, [("Standard_D32", 1)])

    def test_reports_multiple_lines(self):
        path = self.make_file('a = "Standard_D8"\nb = "Standard_E16"\n')
        findings = audit_file(path)
        self.assertIn(("Standard_D8", 1), findings)
        self.assertIn(("Standard_E16", 2), findings)


if __name__ == "__main__":
    unittest.main()
