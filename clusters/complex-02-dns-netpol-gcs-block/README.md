# Cluster Scenario: complex-02

**Project**: `gca-gke-2025`  
**Zone**: `us-central1-a`  
**Scenario**: NetworkPolicy DNS Isolation + Misconfigured StatefulSet Hostname

## Overview
This cluster features a layered networking and DNS failure mode:
1. Namespace `prod-checkout` has a NetworkPolicy (`isolate-dns-egress`) that allows TCP egress to ports 80 and 443, but blocks UDP/TCP egress to port 53 (DNS).
2. Workload `wl-complex-02-checkout-backend` attempts to query an invalid headless DB hostname `db-redis-unreachable.prod-checkout.svc.cluster.local`.
3. The pods enter `CrashLoopBackOff` while attempting name resolution.

## Primary Symptoms
- `wl-complex-02-checkout-backend` pods are in `CrashLoopBackOff`.
- Logs show `FATAL: Could not resolve Redis host!`.

## Triage Instructions
1. Inspect network policies in `prod-checkout`: `kubectl get netpol -n prod-checkout`
2. Update `isolate-dns-egress` NetworkPolicy to allow port 53 egress.
3. Update the deployment environment variable or service reference to point to `redis-headless`.
