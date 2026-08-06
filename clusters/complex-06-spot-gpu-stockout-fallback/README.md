# Cluster Scenario: complex-06

**Project**: `gca-gke-2025`  
**Zone**: `us-central1-a`  
**Scenario**: Spot GPU Stockout & GKE Cluster Autoscaler Scale-Up Deadlock

## Overview
This cluster demonstrates a compute capacity stockout failure during GKE Cluster Autoscaler scale-up:
1. `wl-complex-06-llm-batch-inference` deployment requests 8 replicas matching NVIDIA A100 Spot instances (`a2-ultragpu-1g` on Spot) in `us-central1-a`.
2. GKE Cluster Autoscaler detects pending pods and triggers a scale-up operation on node pool `gpu-a100-spot-pool`.
3. Compute Engine returns `ZONE_RESOURCE_POOL_EXHAUSTED` / `STOCKOUT` for A100 Spot instances in `us-central1-a`.
4. Pods remain stuck in `Pending` with `ScaleUpFailed` events.

## Primary Symptoms
- Workload pods remain in `Pending` state indefinitely.
- Event log: `ScaleUpFailed: pod trigger scale-up failed: zone us-central1-a does not have enough capacity for a2-ultragpu-1g (STOCKOUT / ZONE_RESOURCE_POOL_EXHAUSTED)`.

## Triage Instructions
1. Inspect pending pod scheduling events: `kubectl describe pod -l app=llm-batch-inference`
2. Check Cluster Autoscaler status configmap: `kubectl get configmap cluster-autoscaler-status -n kube-system -o yaml`
3. Fall back to alternative GPU types (e.g. L4 `g2-standard-48` or T4 `n1-standard-16`) or switch node pool location / remove strict Spot requirement.
