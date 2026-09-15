import argparse
import re
import sys
from pathlib import Path

EXPENSIVE_TYPES = {
    "Standard_D8", "Standard_D16", "Standard_D32", "Standard_E16",
    "Standard_E32", "Standard_F64", "Standard_M", "Standard_M32", "Standard_M64",
}


def terraform_files(root=Path(".")):
    return [
        path for path in root.rglob("*.tf")
        if ".git" not in path.parts and ".terraform" not in path.parts
    ]


def audit_file(path, instance_types=EXPENSIVE_TYPES):
    findings = []
    text = path.read_text(encoding="utf-8", errors="ignore")
    for instance_type in instance_types:
        for match in re.finditer(re.escape(instance_type), text):
            line = text.count("\n", 0, match.start()) + 1
            findings.append((instance_type, line))
    return sorted(findings, key=lambda item: (item[1], item[0]))


def main():
    parser = argparse.ArgumentParser(description="Review Terraform for configured high-cost Azure VM instance types.")
    parser.add_argument("--root", type=Path, default=Path("."), help="Terraform project root (default: current directory).")
    parser.add_argument("--instance-type", action="append", dest="instance_types", help="Additional instance type to flag; repeatable.")
    args = parser.parse_args()

    instance_types = set(EXPENSIVE_TYPES)
    if args.instance_types:
        instance_types.update(args.instance_types)

    print("Cloud Waste Auditor: reviewing Terraform for high-cost instance types.")
    files = terraform_files(args.root)
    total = 0
    for path in files:
        for instance_type, line in audit_file(path, instance_types):
            total += 1
            print(f"FINOPS WARNING: {path}:{line}: {instance_type} requires cost review.")

    print(f"\nAudit complete: {len(files)} Terraform file(s), {total} finding(s).")
    if total:
        print("These are review flags, not proof of waste.")
        print("Consider workload requirements, environment, autoscaling and actual cost data.")
        return 1

    print("No configured high-cost instance patterns detected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
