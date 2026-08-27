import re
import sys
from pathlib import Path

EXPENSIVE_TYPES = {
    "Standard_D8",
    "Standard_D16",
    "Standard_D32",
    "Standard_E16",
    "Standard_E32",
    "Standard_F64",
    "Standard_M",
    "Standard_M32",
    "Standard_M64",
}


def terraform_files() -> list[Path]:
    return [
        path
        for path in Path("infra/terraform").rglob("*.tf")
        if ".terraform" not in path.parts
    ]


def main() -> int:
    findings = 0
    files = terraform_files()

    print("Cloud Waste Auditor: reviewing Terraform for configured high-cost VM sizes.")

    for path in files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for instance_type in EXPENSIVE_TYPES:
            for match in re.finditer(re.escape(instance_type), text):
                line = text.count("\n", 0, match.start()) + 1
                findings += 1
                print(
                    f"FINOPS WARNING: {path}:{line}: "
                    f"{instance_type} requires cost review."
                )

    print(f"Audit complete: {len(files)} Terraform file(s), {findings} finding(s).")

    if findings:
        print("These are review flags, not proof of waste.")
        print("Review workload requirements, environment, autoscaling and actual cost data.")
        return 1

    print("No configured high-cost instance patterns detected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
