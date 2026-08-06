# Fleet Cluster: prod-ha-payments-14

**Project**: `gca-gke-test`  
**Zone**: `us-central1-a`  
**Domain**: High-Availability Payment Gateway Infrastructure

## Overview
This cluster hosts high-availability payment gateway infrastructure (`ha-payment-gateway-service`) configured with strict pod affinity rules and internal load balancers in `us-central1-a`.

## Evaluation Ground Truth
For benchmark evaluation ground-truth details, see [`benchmark/ground_truth.json`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/benchmark/ground_truth.json) under scenario `prod-ha-payments-14`.
