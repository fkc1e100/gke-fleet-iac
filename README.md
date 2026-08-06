# Organization Fleet Infrastructure & Workload Monorepo (`org-mono-repo`)

Welcome to **`fkc1e100/org-mono-repo`**, an enterprise-grade monorepo containing multi-cluster GKE fleet infrastructure modules, Config Connector (KCC) GCP infrastructure declarations, OPA Gatekeeper policy-as-code guardrails, reusable Terraform modules, tenant workspace vending definitions, and GitHub Actions CI/CD workflows.

---

## 🌐 GCP Project Portability & Setup for Forks

If you fork this repository to deploy or evaluate SRE agents in your own GCP environment:

1. **Environment Variables**:
   Set `GCP_PROJECT_ID` (or `GCP_PROJECT_2025` and `GCP_PROJECT_TEST`) to your target GCP Project ID:
   ```bash
   export GCP_PROJECT_ID="your-gcp-project-id"
   ```

2. **Terraform Provisioning**:
   Pass your project ID to Terraform when initializing per-cluster IaC:
   ```bash
   cd clusters/prod-core-api-01/terraform
   terraform init
   terraform apply -var="project_id=${GCP_PROJECT_ID}"
   ```

3. **Fleet Operations**:
   The scripts (`deploy_fleet_event_watchers.sh` and `enforce_broken_state.sh`) dynamically read `GCP_PROJECT_ID` or fallback to your active `gcloud` project context (`gcloud config get-value project`).

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
│       └── gke-cluster/                       # Modular GKE cluster, Workload Identity & nodepool IaC
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
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
│   ├── team-analytics/                        # Namespace, ResourceQuota & GPU allocation
│   └── team-checkout/                         # Namespace, ResourceQuota & PodSecurity Restricted
├── clusters/                                  # Fleet Cluster Directories & IaC Configurations
│   ├── prod-core-api-01/
│   ├── prod-user-auth-02/
│   ├── prod-data-pipeline-03/
│   ├── prod-checkout-04/
│   ├── prod-storage-db-05/
│   ├── edge-ingress-gateway-06/
│   ├── prod-api-router-07/
│   ├── batch-analytics-08/
│   ├── ai-training-dws-09/
│   ├── prod-auto-scaler-10/
│   ├── prod-checkout-gateway-11/
│   ├── prod-order-processing-12/
│   ├── prod-catalog-sync-13/
│   ├── prod-ha-payments-14/
│   ├── prod-analytics-store-15/
│   ├── ai-inference-gpu-16/
│   └── hpc-batch-compute-17/
├── manifests/                                 # Kubernetes Manifests & Workload Definitions
│   ├── common/                                # Base fleet event watchers & loadbalancer services
│   ├── labels/                                # Fleet namespace labeling standards
│   └── workloads/                             # Production business domain workload manifests
│       ├── payment-processor.yaml
│       ├── user-auth-service.yaml
│       ├── memory-cache-service.yaml
│       ├── checkout-backend-api.yaml
│       ├── stateful-postgres-db.yaml
│       ├── frontend-web-gateway.yaml
│       ├── api-routing-proxy.yaml
│       ├── batch-report-worker.yaml
│       ├── gemma-fine-tuning-job.yaml
│       ├── queue-worker-service.yaml
│       ├── payment-api-gateway.yaml
│       ├── checkout-backend-service.yaml
│       ├── config-syncer-service.yaml
│       ├── ha-payment-gateway-service.yaml
│       ├── analytics-worker-service.yaml
│       ├── llm-batch-inference-job.yaml
│       └── hpc-batch-analytics-job.yaml
├── rbac/                                      # Fleet ClusterRoles & ClusterRoleBindings
├── docs/                                      # Enterprise Documentation & ADRs
│   └── adr/
├── scripts/
│   ├── deploy_fleet_event_watchers.sh        # Deploys kube-agents watcher daemon across fleet
│   └── enforce_broken_state.sh              # Resets fleet workloads to evaluation states
└── default-deny-netpol.yaml
```

---

## ⚡ Fleet Cluster Portfolio (17 Clusters)

| Cluster Folder Name | GCP Project | Target Workload Manifest | Target Namespace |
|---|---|---|---|
| [`prod-core-api-01`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-core-api-01) | `${GCP_PROJECT_ID}` | `payment-processor.yaml` | `default` |
| [`prod-user-auth-02`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-user-auth-02) | `${GCP_PROJECT_ID}` | `user-auth-service.yaml` | `default` |
| [`prod-data-pipeline-03`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-data-pipeline-03) | `${GCP_PROJECT_ID}` | `memory-cache-service.yaml` | `default` |
| [`prod-checkout-04`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-checkout-04) | `${GCP_PROJECT_ID}` | `checkout-backend-api.yaml` | `default` |
| [`prod-storage-db-05`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-storage-db-05) | `${GCP_PROJECT_ID}` | `stateful-postgres-db.yaml` | `default` |
| [`edge-ingress-gateway-06`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/edge-ingress-gateway-06) | `${GCP_PROJECT_ID}` | `frontend-web-gateway.yaml` | `default` |
| [`prod-api-router-07`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-api-router-07) | `${GCP_PROJECT_ID}` | `api-routing-proxy.yaml` | `default` |
| [`batch-analytics-08`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/batch-analytics-08) | `${GCP_PROJECT_ID}` | `batch-report-worker.yaml` | `default` |
| [`ai-training-dws-09`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/ai-training-dws-09) | `${GCP_PROJECT_ID}` | `gemma-fine-tuning-job.yaml` | `default` |
| [`prod-auto-scaler-10`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-auto-scaler-10) | `${GCP_PROJECT_ID}` | `queue-worker-service.yaml` | `default` |
| [`prod-checkout-gateway-11`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-checkout-gateway-11) | `${GCP_PROJECT_ID}` | `payment-api-gateway.yaml` | `default` |
| [`prod-order-processing-12`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-order-processing-12) | `${GCP_PROJECT_ID}` | `checkout-backend-service.yaml` | `prod-checkout` |
| [`prod-catalog-sync-13`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-catalog-sync-13) | `${GCP_PROJECT_ID}` | `config-syncer-service.yaml` | `prod-apps` |
| [`prod-ha-payments-14`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-ha-payments-14) | `${GCP_PROJECT_ID}` | `ha-payment-gateway-service.yaml` | `default` |
| [`prod-analytics-store-15`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/prod-analytics-store-15) | `${GCP_PROJECT_ID}` | `analytics-worker-service.yaml` | `default` |
| [`ai-inference-gpu-16`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/ai-inference-gpu-16) | `${GCP_PROJECT_ID}` | `llm-batch-inference-job.yaml` | `default` |
| [`hpc-batch-compute-17`](file:///usr/local/google/home/fcurrie/Projects/org-mono-repo/clusters/hpc-batch-compute-17) | `${GCP_PROJECT_ID}` | `hpc-batch-analytics-job.yaml` | `default` |

---

## 🚀 Operations

### Fleet Watcher Deployment
```bash
./scripts/deploy_fleet_event_watchers.sh
```

### Reset Fleet State
```bash
./scripts/enforce_broken_state.sh
```
