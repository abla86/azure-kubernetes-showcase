# ADR 0001: Implementering av Default-Deny Network Policies

## Status
Godkjent / Implementert

## Kontekst
I standard Kubernetes-klynger har podder som utgangspunkt mulighet til å kommunisere med andre podder. En flat kommunikasjonsmodell øker konsekvensen dersom en workload blir kompromittert.

## Beslutning
Vi velger en default-deny nettverksstrategi ved hjelp av Kubernetes NetworkPolicy/Azure CNI, med eksplisitte regler for nødvendig trafikk.

## Konsekvenser
- Tverrtrafikk blokkeres som standard der policyen gjelder.
- Kun eksplisitt godkjent trafikk får passere.
- Sikkerheten økes gjennom least-privilege nettverkskommunikasjon.
- Nye tjenester må få eksplisitt nødvendige kommunikasjonsregler før de kan kommunisere med andre workloads.
- Policyene må testes sammen med health checks, DNS, ingress/gateway og øvrige nødvendige cluster-tjenester.
