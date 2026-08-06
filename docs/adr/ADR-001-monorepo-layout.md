# ADR-001: Consolidated Monorepo Structure for Fleet Infrastructure & Workloads

## Status
**ACCEPTED**

## Context
The enterprise platform infrastructure consists of 17+ GKE clusters across multiple GCP projects (`gca-gke-2025`, `gca-gke-test`). Managing infrastructure, Kubernetes manifests, and policy guardrails across fragmented repositories creates operational drift, authorization friction, and triage delays.

## Decision
Adopt a single consolidated Monorepo (`org-mono-repo`) containing:
1. **`gcp-infrastructure/`**: Declarative GCP Cloud resources managed via Google Cloud Config Connector (KCC).
2. **`clusters/`**: Flat, descriptive per-cluster folders containing IaC definitions (`terraform/`) and event watchers.
3. **`manifests/`**: Canonical application workload deployments and business domain microservices.
4. **`governance/`**: OPA Gatekeeper policy-as-code guardrails.

## Consequences
- **Positive**: Single source of truth for platform engineering, simplified GitOps automation, uniform security controls.
- **Negative**: Requires strict `.github/CODEOWNERS` configuration to control pull request approvals per domain.
