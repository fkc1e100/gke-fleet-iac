# ADR-002: Declarative GCP Resource Management via Config Connector (KCC)

## Status
**ACCEPTED**

## Context
GKE workloads require auxiliary GCP cloud services (Cloud Storage buckets, Cloud SQL databases, KMS encryption keyrings, IAM Workload Identity bindings). Provisioning these via manual Terraform runs outside the GitOps workflow breaks continuous deployment cycles.

## Decision
Adopt **Google Cloud Config Connector (KCC)** (`*.cnrm.cloud.google.com`) to declare GCP resources directly as Kubernetes Custom Resources under `gcp-infrastructure/`.

## Consequences
- **Positive**: Cloud resources are managed natively via GitOps pipelines alongside Kubernetes application workloads.
- **Negative**: Requires Config Connector operator running in the management cluster.
