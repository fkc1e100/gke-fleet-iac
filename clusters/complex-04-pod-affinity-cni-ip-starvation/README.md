# Cluster Scenario: complex-04

**Project**: `gca-gke-test`  
**Zone**: `us-central1-a`  
**Scenario**: Pod Anti-Affinity Scheduling Deadlock + CNI IP Starvation + Over-allocated Requests

## Overview
This cluster combines scheduling anti-affinity deadlocks and resource over-allocation:
1. `cni-ip-hog` consumes 35 Pod IPs, stressing CNI pod CIDR allocation.
2. `wl-complex-04-ha-payment-gateway` requests 4 replicas with strict `podAntiAffinity` (`topologyKey: kubernetes.io/hostname`) across a 2-node cluster.
3. Each replica requests 4 CPUs on nodes with only 2 CPUs.

## Primary Symptoms
- Pod state: `Pending`
- Scheduler events: `0/2 nodes are available: 2 Insufficient cpu, 2 node(s) didn't match pod anti-affinity rules`.

## Triage Instructions
1. Inspect pending pod events: `kubectl describe pod -l app=ha-payment-gateway`
2. Reduce CPU requests on `wl-complex-04-ha-payment-gateway` to fit within node CPU specs.
3. Relax `podAntiAffinity` to `preferredDuringSchedulingIgnoredDuringExecution` or scale up cluster nodes.
4. Scale down `cni-ip-hog` deployment to release CNI IP allocation pressure.
