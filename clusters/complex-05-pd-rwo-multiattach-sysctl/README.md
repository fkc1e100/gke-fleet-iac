# Cluster Scenario: complex-05

**Project**: `gca-gke-test`  
**Zone**: `us-central1-a`  
**Scenario**: Storage RWO Multi-Attach Lockout + Failing InitContainer Sysctl Violation

## Overview
This cluster features a storage attachment conflict combined with failing initContainers:
1. `wl-complex-05-analytics-worker` deployment has 2 replicas bound to a single ReadWriteOnce PersistentVolumeClaim (`pvc-analytics-store`).
2. Pod replica #2 cannot attach the volume concurrently across nodes (`Multi-Attach error`).
3. Replica #1 fails inside its `init-sysctl` initContainer because `sysctl` requires privileged security context capabilities, which are withheld (`Permission denied`).

## Primary Symptoms
- Pod #1 status: `Init:CrashLoopBackOff` (`sysctl: Permission denied`).
- Pod #2 status: `ContainerCreating` (`Multi-Attach error for volume "pvc-analytics-store"`).

## Triage Instructions
1. Inspect deployment & pod events: `kubectl describe pod -l app=analytics-worker`
2. Change access mode or set deployment replicas to 1 (or convert to ReadWriteMany / StatefulSet with volumeClaimTemplates).
3. Grant required security context capabilities or remove the unprivileged sysctl initContainer.
