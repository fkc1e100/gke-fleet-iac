# Cluster Scenario: complex-01

**Project**: `gca-gke-2025`  
**Zone**: `us-central1-a`  
**Scenario**: Cluster-Wide Admission Mutating Webhook Deadlock & Intercepted System Pods

## Overview
This cluster demonstrates a multi-fault API server admission control outage:
1. A cluster-wide `MutatingWebhookConfiguration` (`fleet-policy-enforcer`) intercepts all pod `CREATE` and `UPDATE` calls with `failurePolicy: Fail`.
2. The targeted webhook backend deployment `admission-webhook-server` in `webhook-system` namespace is in `ImagePullBackOff`.
3. Any attempt to create new workloads or apply fixes to deployments fails with API admission timeouts / unreachable webhook backend errors.

## Primary Symptoms
- `kubectl apply` or deployment rollouts fail with:
  `Internal error occurred: failed calling webhook "fleet-policy-enforcer.kube-agents.io": Post "https://admission-webhook-svc.webhook-system.svc:443/mutate?timeout=10s": service "admission-webhook-svc" not found`
- `wl-complex-01-payment-api` deployment cannot create pods or scale up.

## Triage Instructions
1. Inspect mutating webhook configurations: `kubectl get mutatingwebhookconfigurations`
2. Inspect webhook backend pods in `webhook-system`.
3. Either delete/disable the mutating webhook configuration or fix its namespace selector / backend endpoint to restore API pod creation capability.
