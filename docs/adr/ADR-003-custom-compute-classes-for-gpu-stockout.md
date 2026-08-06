# ADR-003: GKE Custom ComputeClasses for Multi-Tier Hardware Stockout Fallback

## Status
**ACCEPTED**

## Context
High-demand compute workloads (NVIDIA A100 Spot GPUs, high-core vCPU instances) frequently encounter `ZONE_RESOURCE_POOL_EXHAUSTED` (stockout) errors during Cluster Autoscaler scale-up events. Hardcoding specific node selectors in workload manifests causes scheduling failures when a specific hardware SKU is unavailable in GCP.

## Decision
Adopt **GKE Custom ComputeClasses** (`cloud.google.com/v1` `ComputeClass`) to define hardware abstractions with prioritized fallback tiers (e.g. A100 Spot primary -> L4 GPU fallback).

## Consequences
- **Positive**: Decouples application deployment manifests from underlying GCP hardware SKUs and mitigates stockout failures automatically.
- **Negative**: Requires platform team maintenance of `ComputeClass` definitions across zones.
