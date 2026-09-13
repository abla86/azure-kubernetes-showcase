# Test Failure Policy

This repository follows a strict verification rule:

- Missing required test -> FAIL
- Missing required file -> FAIL
- Expected behavior not verified -> FAIL
- Failed assertion -> FAIL
- Tooling/configuration error -> FAIL
- Successful test suite -> PASS

A failure must identify the exact missing or broken control and must not be represented as verified until the corresponding file, implementation, or test exists and passes.

## Required response to missing files

When an automated check detects a required file is missing, the maintenance process must:

1. Fail the check.
2. Report the exact expected path.
3. State which contract requires the file.
4. Create or repair the file when the required implementation is unambiguous and safe.
5. Re-run the relevant validation before claiming success.

The process must never silently skip a missing test or replace evidence with documentation alone.
