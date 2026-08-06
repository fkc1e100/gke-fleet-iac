# Enterprise Architecture Review Board (ARB) Mandate & Deployment Standards

**Organization**: OmniRetail Global Infrastructure & Platform Engineering  
**Document Version**: 3.0 (PCI-DSS 4.0 Enhanced)  
**Classification**: Enterprise Internal Infrastructure Standard  

---

## 🏛️ Executive Summary

This document establishes the **10 Mandatory Infrastructure & Deployment Rules** and **PCI-DSS 4.0 Cardholder Data Environment (CDE) Governance Rules** established by the Enterprise Architecture Review Board (ARB). All infrastructure operators, platform engineers, and application developers deploying resources to GKE fleets or Google Compute Engine (GCE) within `org-mono-repo` MUST comply with these architectural standards.

---

## 💳 PCI-DSS 4.0 Cardholder Data Environment (CDE) Mandates

For all workloads operating within PCI-scoped payment namespaces (`prod-payments`, `prod-checkout`):

1. **PCI Requirement 1 (CDE Microsegmentation)**: Microservices handling Cardholder Data (CHD) MUST operate in isolated CDE namespaces (`prod-payments`). Direct ingress from non-CDE namespaces is blocked via zero-trust NetworkPolicies.
2. **PCI Requirement 3 & 4 (Encryption at Rest & In-Transit)**: Payment data stored in Cloud Storage or databases MUST use Customer-Managed Encryption Keys (CMEK) via GCP KMS (`KMSCryptoKey`). All intra-cluster and external communication MUST enforce TLS 1.3 encryption.
3. **PCI Requirement 7 & 8 (Least Privilege IAM & RBAC)**: Kubernetes ServiceAccounts in CDE namespaces MUST use granular Workload Identity IAM roles. `cluster-admin` bindings and shared service accounts are strictly prohibited.
4. **PCI Requirement 10 (Audit Logging & Event Daemon Watchers)**: All Kubernetes API server events, pod mutations, and security events in CDE namespaces MUST be continuously ingested by `cluster-agent-event-watcher` daemons and streamed to immutable GCS audit log sinks.
5. **PCI Requirement 11 (Automated CVE Vulnerability Scanning)**: Container images deployed to `prod-payments` MUST be scanned for CVEs via Trivy/Container Analysis pipelines. Images containing Critical CVEs are rejected at admission time by OPA Gatekeeper.

---

## 📜 The 10 Enterprise Infrastructure & Deployment Rules

### 1. Mandatory FinOps & Cost Center Tagging
All Kubernetes `Namespace` declarations and GCE `ComputeInstance` resources MUST include standardized FinOps chargeback labels:
- `cost-center`: Standard financial code (e.g. `finops-payments-101`, `finops-checkout-404`).
- `owner`: Responsible domain engineering team (e.g. `payments-team`, `checkout-team`).

---

### 2. Zero-Trust Network Perimeter & Explicit Egress Declarations
All application namespaces MUST deploy a default-deny NetworkPolicy baseline (`default-deny-netpol.yaml`). Microservices requesting egress to internal VPC subnets, GCE VM instances, or public endpoints MUST explicitly declare `NetworkPolicy` egress allow rules.

---

### 3. GCP Workload Identity Enforcement (No Static Keys)
Microservices requiring access to GCP APIs (Secret Manager, Cloud Storage, KMS, CloudSQL) MUST use GKE Workload Identity binding Kubernetes ServiceAccounts to GCP IAM Service Accounts (`iam.gke.io/gcp-service-account`). Static JSON service account keys are strictly prohibited.

---

### 4. Mandatory CPU Requests & Memory Limits for HPA Workloads
All containerized deployments utilizing Horizontal Pod Autoscalers (HPA) MUST specify explicit `resources.requests.cpu` and `resources.limits.memory`. Omission of CPU requests on HPA-managed workloads is blocked to prevent scheduler starvation.

---

### 5. Multi-Tier Hardware Abstraction via Custom ComputeClasses
AI/ML inference, model fine-tuning, and HPC batch analytics workloads MUST target GKE `ComputeClass` abstractions (`cloud.google.com/v1`) rather than hardcoding specific GCP machine types or GPU SKUs, ensuring automatic multi-tier fallback during zonal stockout events (`ZONE_RESOURCE_POOL_EXHAUSTED`).

---

### 6. Admission Security Guardrails (OPA Gatekeeper Policy Compliance)
All manifests submitted to GKE fleets are evaluated against OPA Gatekeeper policies. Manifests requesting `securityContext.privileged: true` or referencing unapproved container registries outside `gcr.io`, `us-docker.pkg.dev`, or `registry.k8s.io` will be rejected at admission time.

---

### 7. Managed Instance Group (MIG) Autohealing Governance
GCE Compute Engine VM workloads operating in production MUST be deployed as Managed Instance Groups (MIGs) backed by dedicated `ComputeHealthCheck` probes on HTTP/HTTPS endpoints (`/healthz`). Service Accounts used by MIG instances must have requisite GCP IAM permissions prior to autohealing activation.

---

### 8. Boot Disk Capacity & Telemetry Log Retention Rules
GCE VM instances MUST implement log rotation policies (`logrotate`) or run the Google Cloud Ops Agent to prevent boot disk 100% capacity exhaustion and Systemd journald locks.

---

### 9. Multi-Tenant Workspace Vending & Security Standards
Tenant teams (`team-checkout`, `team-analytics`) MUST operate within vended tenant namespaces enforced with Kubernetes Pod Security `baseline` or `restricted` standards and bound by `ResourceQuota` limits.

---

### 10. Immutable GitOps Infrastructure Reconciliation
All Kubernetes manifests, GCE VM infrastructure, and GCP Cloud resources MUST be declared as code within `org-mono-repo` and reconciled continuously via ArgoCD or Google Cloud Config Connector (KCC). Manual out-of-band `gcloud` or `kubectl` mutations in production are forbidden.
