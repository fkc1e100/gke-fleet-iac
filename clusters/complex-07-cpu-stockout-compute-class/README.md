# Cluster Scenario: complex-07-cpu-stockout-compute-class

**Project**: `gca-gke-test`  
**Zone**: `us-central1-a`  
**Scenario**: High-Core vCPU Spot Stockout & Custom ComputeClass Autoscaling Failure

## Overview
This cluster demonstrates a high-vCPU compute capacity stockout failure during GKE Cluster Autoscaler scale-up:
1. `wl-complex-07-hpc-batch-analytics` deployment requests 16 replicas, each requiring 56 vCPUs and 200Gi RAM matching `cpu-hpc-compute-class` (primary: `c2-standard-60` Spot, fallback: `c3-standard-88` Spot) in `us-central1-a`.
2. GKE Cluster Autoscaler detects pending pods and triggers scale-up on `c2-standard-60` Spot node pools.
3. Compute Engine returns `ZONE_RESOURCE_POOL_EXHAUSTED` / `STOCKOUT` for `c2-standard-60` Spot vCPUs in `us-central1-a`.
4. Pods remain stuck in `Pending` with `ScaleUpFailed` events.

## Primary Symptoms
- Workload pods remain in `Pending` state indefinitely.
- Event log: `ScaleUpFailed: pod trigger scale-up failed: zone us-central1-a does not have enough vCPU capacity for c2-standard-60 (STOCKOUT / ZONE_RESOURCE_POOL_EXHAUSTED)`.

## Triage Instructions
1. Inspect pending pod scheduling events: `kubectl describe pod -l app=hpc-batch-analytics`
2. Check Cluster Autoscaler status configmap: `kubectl get configmap cluster-autoscaler-status -n kube-system -o yaml`
3. Fall back to standard `n2-standard-64` instance families or expand the `ComputeClass` priorities to include multi-zone placement.
