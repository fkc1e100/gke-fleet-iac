# Organization Fleet Infrastructure & Workload Monorepo (`org-mono-repo`)

Welcome to **`fkc1e100/org-mono-repo`**, an enterprise-grade monorepo engineered for a **Global Multi-Brand Retail Enterprise** operating under strict regulatory compliance frameworks including **PCI-DSS 4.0, SOC 2 Type II, GDPR / CCPA, ISO/IEC 27001, and SOX Section 404**.

This repository contains multi-cluster GKE fleet infrastructure modules, Compute Engine (GCE) VM declarations, Config Connector (KCC) GCP infrastructure declarations, OPA Gatekeeper policy-as-code guardrails, reusable Terraform modules, tenant workspace vending definitions, and GitHub Actions CI/CD workflows.

> [!NOTE]
> **Zero-Prerequisite Onboarding**: All scripts (`deploy_gce_vms_terraform.sh`, `enforce_broken_state.sh`, `setup_argocd_gitops.sh`) include an automated **GCP Auth Check & Project Wizard**. If not logged in, they automatically run `gcloud auth login` and `gcloud auth application-default login`, then prompt interactively for single or dual project IDs.

---

## 🏛️ Enterprise Regulatory Compliance Regimes

Our retail platform infrastructure complies with five mandatory enterprise security and privacy frameworks:

1. **💳 PCI-DSS 4.0 (Payment Card Industry Data Security Standard)**: Enforces Cardholder Data Environment (CDE) microsegmentation (`prod-payments`), KMS encryption at rest, TLS 1.3 in-transit, least-privilege Workload Identity, and audit logging.
2. **🛡️ SOC 2 Type II (Security, Availability, Confidentiality)**: Enforces zero-trust NetworkPolicy boundaries, OPA Gatekeeper admission guardrails, automated container vulnerability scanning, and CODEOWNERS PR approval governance.
3. **🔒 GDPR & CCPA (Global Data Privacy & PII Protection)**: Enforces customer Personally Identifiable Information (PII) data isolation across European and US regional VPC subnets and storage buckets.
4. **🏢 ISO/IEC 27001 (Information Security Management)**: Standardized infrastructure-as-code (IaC) governance, automated pre-commit hook scanning, and continuous Trivy vulnerability reviews.
5. **📊 SOX Section 404 (Financial Reporting Systems Integrity)**: Immutable audit logging streaming audit logs to tamper-proof GCP Cloud Storage buckets for e-commerce financial transactions.

For complete Architectural Mandates, refer to **[`docs/architecture-board-guidelines.md`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/docs/architecture-board-guidelines.md)**.

---

## 🔗 Hybrid GKE ↔ GCE Inter-Service Dependencies

In enterprise production architectures, GKE Kubernetes microservices connect to backend GCE VM infrastructure over VPC internal IP addresses. Failure in GCE VM infrastructure cascades into GKE workload health:

```text
GKE Fleet Microservices                  Backend GCE VM Infrastructure
┌────────────────────────────────┐       ┌──────────────────────────────────────┐
│ prod-checkout-gateway-11       │ ─────>│ prod-payment-mig-gateway (10.128.0.50) │
│ (payment-api-gateway)          │       │ (MIG Autohealing IAM Lockout)        │
└────────────────────────────────┘       └──────────────────────────────────────┘
┌────────────────────────────────┐       ┌──────────────────────────────────────┐
│ prod-user-auth-02              │ ─────>│ prod-auth-legacy-vm (10.128.0.25)   │
│ (user-auth-service)            │       │ (Legacy VM Package Installation Fail)│
└────────────────────────────────┘       └──────────────────────────────────────┘
┌────────────────────────────────┐       ┌──────────────────────────────────────┐
│ prod-analytics-store-15        │ ─────>│ prod-finops-telemetry-exporter       │
│ (analytics-worker-service)     │       │ (10.128.0.99 - Ops Agent IAM Crash)  │
└────────────────────────────────┘       └──────────────────────────────────────┘
```

---

## 🚀 Getting Started: GitOps & IaC Provisioning

### Option 1: Automated Terraform IaC Deployment (Recommended)

To provision or reset all GCE VM instances and cluster resources via Terraform (includes automated `gcloud auth` login and project wizard):

```bash
# Provision / Reset all GCE VM instances via automated Terraform IaC
./scripts/deploy_gce_vms_terraform.sh

# Reset GKE fleet workloads to canonical broken evaluation state
./scripts/enforce_broken_state.sh
```

---

### Option 2: Automated ArgoCD GitOps Continuous Sync

For GitOps-driven environments, run the 1-command ArgoCD setup script:

```bash
# Automated ArgoCD installation, fork binding & GitOps Application sync
./scripts/setup_argocd_gitops.sh
```

---

### Option 3: Syncing into an Existing Repository (Git Remote / Subtree)

#### Method A: Upstream Remote Sync (For Existing Forked Repositories)
To continuously synchronize upstream improvements into an existing repository:
```bash
# 1. Add org-mono-repo as an upstream remote
git remote add upstream https://github.com/fkc1e100/org-mono-repo.git

# 2. Fetch latest changes from upstream
git fetch upstream

# 3. Rebase upstream main into your active main branch
git checkout main
git rebase upstream/main

# 4. Push updated main to your remote repository
git push origin main --force
```

#### Method B: Git Subtree Sync (Integrating into an Existing Monorepo Subfolder)
To import `org-mono-repo` as a subfolder (e.g. `eval-platform/`) within an existing enterprise monorepo:
```bash
# 1. Add org-mono-repo as a subfolder in your existing repository
git subtree add --prefix=eval-platform https://github.com/fkc1e100/org-mono-repo.git main --squash

# 2. Pull future updates from upstream into your subfolder
git subtree pull --prefix=eval-platform https://github.com/fkc1e100/org-mono-repo.git main --squash
```

---

## 🏛️ Enterprise Monorepo Architecture

```text
org-mono-repo/
├── .github/                                    # Enterprise CI/CD & Automated Review Bots
│   ├── dependabot.yml                         # Dependabot automated dependency review bot
│   ├── workflows/
│   │   ├── terraform-ci.yaml                  # Terraform format, tflint, and validation checks
│   │   ├── policy-scan.yaml                   # Conftest policy-as-code validation on PRs
│   │   ├── trivy-security-bot.yaml            # Trivy automated security review bot
│   │   ├── pr-title-linter.yaml               # Semantic PR title linter bot
│   │   └── stale-bot.yaml                     # Automated stale PR and issue triage bot
│   └── CODEOWNERS                             # Granular PR approval enforcement
├── .pre-commit-config.yaml                    # Local workstation git pre-commit hooks
├── terraform/                                 # Standardized Reusable IaC Core
│   └── modules/
│       ├── gke-cluster/                       # Reusable GKE cluster & nodepool Terraform module
│       └── gce-instance/                      # Reusable GCE VM Compute Engine Terraform module
├── gce/                                       # Compute Engine (GCE) VM & Hybrid Compute Infrastructure
│   ├── argocd-app.yaml                        # ArgoCD GitOps Application for GCE continuous sync
│   ├── terraform/                             # Root Terraform Workspace for GCE Instances (main.tf)
│   ├── prod-auth-legacy-vm/                   # Legacy Auth GCE VM infrastructure & startup script
│   ├── prod-audit-logger-vm/                  # Audit logger GCE VM infrastructure & disk spooling
│   ├── prod-payment-mig-gateway/              # Managed Instance Group template & autohealing health check
│   ├── prod-edge-bastion-gateway/             # Edge bastion GCE VM networking, firewall & route specs
│   └── prod-finops-telemetry-exporter/        # FinOps telemetry exporter GCE VM & Ops Agent config
├── gcp-infrastructure/                        # Config Connector (KCC) GCP Resources as Code
│   ├── database/                              # CloudSQL SQLInstance & SQLDatabase KCC CRDs
│   ├── iam/                                   # Workload Identity IAMServiceAccount & IAMPolicyBinding
│   ├── kms/                                   # Customer-Managed Encryption Keys (KMSKeyRing, KMSCryptoKey)
│   ├── networking/                            # ComputeNetwork VPC & ComputeSubnetwork KCC CRDs
│   └── storage/                               # StorageBucket & Access Control KCC CRDs
├── governance/                                # Policy-as-Code & Security Guardrails
│   └── gatekeeper/constraints/
│       ├── disallow-privileged-containers.yaml
│       ├── enforce-allowed-registries.yaml
│       └── require-finops-labels.yaml
├── tenants/                                   # Multi-Tenancy Self-Service Workspace Vending
├── clusters/                                  # Fleet Cluster Directories & IaC Configurations
├── manifests/                                 # Kubernetes Manifests & Workload Definitions
├── rbac/                                      # Fleet ClusterRoles & ClusterRoleBindings
├── docs/                                      # Enterprise Documentation & ADRs
│   ├── adr/                                   # Architecture Decision Records (ADR-001, ADR-002, ADR-003)
│   └── architecture-board-guidelines.md       # Architecture Review Board (ARB) 10 Deployment Mandates
├── scripts/
│   ├── setup_argocd_gitops.sh                 # Automated ArgoCD validator, installer & fork binder
│   ├── deploy_gce_vms_terraform.sh           # Automated Terraform IaC provisioner for GCE instances
│   └── enforce_broken_state.sh              # Resets both GKE fleet workloads & GCE VM states
└── default-deny-netpol.yaml
```

---

## ⚡ Fleet Cluster Portfolio (17 Clusters)

| Cluster Folder Name | GCP Project | Target Workload Manifest | Enterprise Target Namespace | Hybrid GCE Dependency |
|---|---|---|---|---|
| [`prod-core-api-01`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-core-api-01) | `${GCP_PROJECT_ID}` | `payment-processor.yaml` | `prod-payments` | — |
| [`prod-user-auth-02`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-user-auth-02) | `${GCP_PROJECT_ID}` | `user-auth-service.yaml` | `prod-auth` | 🔗 `prod-auth-legacy-vm` (`10.128.0.25`) |
| [`prod-data-pipeline-03`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-data-pipeline-03) | `${GCP_PROJECT_ID}` | `memory-cache-service.yaml` | `prod-caching` | — |
| [`prod-checkout-04`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-checkout-04) | `${GCP_PROJECT_ID}` | `checkout-backend-api.yaml` | `prod-checkout` | — |
| [`prod-storage-db-05`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-storage-db-05) | `${GCP_PROJECT_ID}` | `stateful-postgres-db.yaml` | `prod-databases` | — |
| [`edge-ingress-gateway-06`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/edge-ingress-gateway-06) | `${GCP_PROJECT_ID}` | `frontend-web-gateway.yaml` | `prod-ingress` | — |
| [`prod-api-router-07`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-api-router-07) | `${GCP_PROJECT_ID}` | `api-routing-proxy.yaml` | `prod-gateway` | — |
| [`batch-analytics-08`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/batch-analytics-08) | `${GCP_PROJECT_ID}` | `batch-report-worker.yaml` | `batch-processing` | — |
| [`ai-training-dws-09`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/ai-training-dws-09) | `${GCP_PROJECT_ID}` | `gemma-fine-tuning-job.yaml` | `ai-training` | — |
| [`prod-auto-scaler-10`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-auto-scaler-10) | `${GCP_PROJECT_ID}` | `queue-worker-service.yaml` | `prod-workers` | — |
| [`prod-checkout-gateway-11`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-checkout-gateway-11) | `${GCP_PROJECT_ID}` | `payment-api-gateway.yaml` | `prod-payments` | 🔗 `prod-payment-mig-gateway` (`10.128.0.50`) |
| [`prod-order-processing-12`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-order-processing-12) | `${GCP_PROJECT_ID}` | `checkout-backend-service.yaml` | `prod-checkout` | — |
| [`prod-catalog-sync-13`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-catalog-sync-13) | `${GCP_PROJECT_ID}` | `config-syncer-service.yaml` | `prod-catalog` | — |
| [`prod-ha-payments-14`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-ha-payments-14) | `${GCP_PROJECT_ID}` | `ha-payment-gateway-service.yaml` | `prod-payments` | — |
| [`prod-analytics-store-15`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-analytics-store-15) | `${GCP_PROJECT_ID}` | `analytics-worker-service.yaml` | `prod-analytics` | 🔗 `prod-finops-telemetry-exporter` (`10.128.0.99`) |
| [`ai-inference-gpu-16`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/ai-inference-gpu-16) | `${GCP_PROJECT_ID}` | `llm-batch-inference-job.yaml` | `ai-inference` | — |
| [`hpc-batch-compute-17`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/hpc-batch-compute-17) | `${GCP_PROJECT_ID}` | `hpc-batch-analytics-job.yaml` | `hpc-batch` | — |

---

## 🖥️ Compute Engine (GCE) VM Portfolio (5 Environments)

| GCE Scenario Folder | Target Resource | GCP Project | Target Namespace | Complexity Level | Primary Failure Domain |
|---|---|---|---|---|---|
| [`prod-auth-legacy-vm`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/gce/prod-auth-legacy-vm) | `prod-legacy-auth-vm` | `${GCP_PROJECT_ID}` | `prod-auth` | 🟢 Simple | Startup script package installation failure without egress network access. |
| [`prod-audit-logger-vm`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/gce/prod-audit-logger-vm) | `prod-audit-logger-vm` | `${GCP_PROJECT_ID}` | `prod-analytics` | 🟢 Simple | Boot disk unrotated logs hit 100% disk capacity, locking `systemd-journald`. |
| [`prod-payment-mig-gateway`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/gce/prod-payment-mig-gateway) | `prod-mig-payment-gateway` | `${GCP_PROJECT_ID}` | `prod-payments` | 🔴 Complex | Managed Instance Group (MIG) autohealing loop caused by VM service account missing Secret Manager IAM permissions. |
| [`prod-edge-bastion-gateway`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/gce/prod-edge-bastion-gateway) | `prod-edge-bastion-vm` | `${GCP_PROJECT_ID}` | `prod-gateway` | 🔴 Complex | VPC Firewall denies TCP 22/443 ingress while custom static route `0.0.0.0/0` points to a deleted Next Hop Gateway. |
| [`prod-finops-telemetry-exporter`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/gce/prod-finops-telemetry-exporter) | `prod-finops-exporter-vm` | `${GCP_PROJECT_ID}` | `prod-analytics` | 🔴 Complex | Google Cloud Ops Agent daemon crashes continuously because VM service account lacks `roles/logging.logWriter` IAM permissions. |

---

## 🚀 Operations

### Setup ArgoCD GitOps Continuous Sync
```bash
./scripts/setup_argocd_gitops.sh
```

### Provision / Reset GCE VM Infrastructure via Terraform
```bash
./scripts/deploy_gce_vms_terraform.sh
```

### Reset Entire Fleet & GCE Evaluation State
```bash
./scripts/enforce_broken_state.sh
```
