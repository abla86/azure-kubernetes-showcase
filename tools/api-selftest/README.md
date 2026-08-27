# API Self-Test / Endpoint Canaries

A controlled API self-test harness for the local showcase stack.

## What it checks

The test probes a fixed set of expected and suspicious-looking routes against **localhost only**:

- health endpoint
- Swagger document
- community resource endpoint
- admin-like route
- `.env`
- `config.json`
- metrics endpoint
- the showcase ghost route

The expected-status model deliberately treats `401`, `403` and `404` as valid outcomes for protected or non-existent routes. This follows the basic principle that an endpoint being absent or access-controlled is preferable to accidentally exposing sensitive content. OWASP recommends testing documented and undocumented API attack surface and checking for excessive data exposure. citeturn504190search0turn504190search5

## Safety boundary

The target is restricted in code to `localhost`, `127.0.0.1` and `::1`. This is an application self-test, not a general-purpose Internet scanner.

## Run locally

```powershell
python tools/api-selftest/api_fuzzer.py --target http://localhost:5001
```

## Exit codes

- `0` = all checks passed
- `1` = one or more checks failed
- `2` = invalid target configuration
