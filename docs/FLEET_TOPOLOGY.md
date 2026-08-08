# Global Fleet Topology & Workload Mapping

This document provides a comprehensive mapping of the **Organization ➔ Project ➔ Region ➔ Cluster ➔ Workload** hierarchy managed by this repository across Google Cloud.

---

## 🏢 Multi-Organization Architecture Overview

The multi-cluster fleet spans across **two distinct Google Cloud Organizations**:
* **🏢 Primary Production Organization (`926317919369`)**: Hosts `gca-gke-2025` (Core Transactional & AI Platform).
* **🏢 Dedicated Fleet & Sandbox Organization (`433637338589`)**: Hosts `gca-gke-test` under the `dev_projects` hierarchy (Edge Routing, Analytics & HA Gateways).

```mermaid
flowchart TD
    subgraph ORG1["🏢 Primary Production Organization (ID: 926317919369)"]
        P1["Project: gca-gke-2025 (764460891170)<br>Core Platform & AI Host"]
        
        EU1["Europe (europe-west1 / europe-west3)"]
        APAC1["Asia-Pacific (asia-east1 / asia-southeast1)"]
        US1["Americas (us-central1 / us-east / us-west)"]

        P1 --> EU1
        P1 --> APAC1
        P1 --> US1

        EU1 --> C_DWS_EU["ai-training-dws-09 (europe-west1-b)<br>gemma-fine-tuning-job"]
        EU1 --> C_CHKG_EU["prod-checkout-gateway-11 (europe-west3-a)<br>checkout-backend"]

        APAC1 --> C_ORD_APAC["prod-order-processing-12 (asia-east1-a)<br>config-syncer"]
        APAC1 --> C_INF_APAC["ai-inference-gpu-16 (asia-southeast1-a)<br>llm-batch-inference"]

        US1 --> C_CORE_US["prod-core-api-01 (us-central1-a)<br>payment-processor"]
        US1 --> C_AUTH_US["prod-user-auth-02 (us-central1-a)<br>user-auth-service"]
        US1 --> C_CHK_US["prod-checkout-04 (us-east4-a / us-central1-a)<br>checkout-backend-api / db-redis"]
        US1 --> C_PIPE_US["prod-data-pipeline-03 (us-east1-b / us-central1-a)<br>memory-cache / queue-worker"]
        US1 --> C_DB_US["prod-storage-db-05 (us-west1-a / us-central1-a)<br>stateful-postgres-db"]
        US1 --> C_BATCH_US["batch-analytics-08 (us-west2-a / us-central1-a)<br>batch-report-worker"]
        US1 --> C_INF_US["ai-inference-gpu-16 (us-central1-a)<br>llm-batch-inference (A100 GPU)"]
    end

    subgraph ORG2["🏢 Fleet & Sandbox Organization (ID: 433637338589)"]
        FOLDER["Folder: dev_projects (657923791383)"]
        P2["Project: gca-gke-test (825476174734)<br>Edge & Analytics Fleet"]
        
        FOLDER --> P2

        EU2["Europe (europe-west1 / europe-west3)"]
        APAC2["Asia-Pacific (asia-east1 / asia-southeast1)"]
        US2["Americas (us-central1 / us-east / us-west)"]

        P2 --> EU2
        P2 --> APAC2
        P2 --> US2

        EU2 --> T_CAT_EU["prod-catalog-sync-13 (europe-west1-c)<br>config-syncer (Catalog)"]
        EU2 --> T_PAY_EU["prod-ha-payments-14 (europe-west3-b)<br>ha-payment-gateway"]

        APAC2 --> T_STORE_APAC["prod-analytics-store-15 (asia-east1-b)<br>analytics-worker (Shared PVC)"]
        APAC2 --> T_HPC_APAC["hpc-batch-compute-17 (asia-southeast1-b)<br>hpc-batch-analytics"]

        US2 --> T_ING_US["edge-ingress-gateway-06 (us-central1-a)<br>frontend-web-gateway (Ingress)"]
        US2 --> T_ROUT_US["prod-api-router-07 (us-east1-c / us-central1-a)<br>api-routing-proxy"]
        US2 --> T_AUTO_US["prod-auto-scaler-10 (us-west1-b / us-central1-a)<br>queue-worker-hpa"]
        US2 --> T_HPC_US["hpc-batch-compute-17 (us-central1-a)<br>hpc-batch-analytics (CPU Class)"]
    end
```

---

## 1. Organization `926317919369` / Project: `gca-gke-2025` *(Core Services & Platform)*

### 🇪🇺 Europe Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`ai-training-dws-09`** | `europe-west1-b` *(Belgium)* | `ai-training` | `Job/gemma-fine-tuning-job` | DWS Gemma model training | `manifests/workloads/gemma-fine-tuning-job.yaml` |
| **`prod-checkout-gateway-11`** | `europe-west3-a` *(Frankfurt)* | `prod-checkout` | `Deployment/checkout-backend` | EU checkout routing gateway | `manifests/workloads/checkout-backend-service.yaml` |

### 🌏 Asia-Pacific Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`prod-order-processing-12`** | `asia-east1-a` *(Taiwan)* | `prod-apps` | `Deployment/config-syncer`<br/>`ServiceAccount/restricted-sa` | APAC order lifecycle sync | `manifests/workloads/config-syncer-service.yaml` |
| **`ai-inference-gpu-16`** | `asia-southeast1-a` *(Singapore)* | `ai-inference` | `Deployment/llm-batch-inference` | APAC GPU LLM batch inference | `manifests/workloads/llm-batch-inference-job.yaml` |

### 🇺🇸 Americas Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`prod-core-api-01`** | `us-central1-a` | `prod-payments` | `Deployment/payment-processor` | Core payment transactions | `manifests/workloads/payment-processor.yaml` |
| **`prod-user-auth-02`** | `us-central1-a` | `prod-auth` | `Deployment/user-auth-service` | User identity & JWT auth tokens | `manifests/workloads/user-auth-service.yaml` |
| **`prod-checkout-04`** | `us-east4-a` / `us-central1-a` | `prod-checkout` | `Deployment/checkout-backend-api`<br/>`StatefulSet/db-redis` | E-commerce checkout backend | `manifests/workloads/checkout-backend-api.yaml`<br/>`manifests/workloads/checkout-backend-service.yaml` |
| **`prod-data-pipeline-03`** | `us-east1-b` / `us-central1-a` | `prod-caching`<br/>`prod-workers` | `Deployment/memory-cache-service`<br/>`Deployment/queue-worker-service` | Redis caching & async queues | `manifests/workloads/memory-cache-service.yaml`<br/>`manifests/workloads/queue-worker-service.yaml` |
| **`prod-storage-db-05`** | `us-west1-a` / `us-central1-a` | `prod-databases` | `Deployment/stateful-postgres-db`<br/>`PVC/postgres-data-pvc` | Relational database tier | `manifests/workloads/stateful-postgres-db.yaml` |
| **`batch-analytics-08`** | `us-west2-a` / `us-central1-a` | `batch-processing` | `Deployment/batch-report-worker-processor` | Scheduled analytical ETL | `manifests/workloads/batch-report-worker.yaml` |
| **`ai-inference-gpu-16`** | `us-central1-a` | `ai-inference` | `Deployment/llm-batch-inference`<br/>`ComputeClass/a100-gpu-class` | High-throughput GPU inference | `clusters/ai-inference-gpu-16/compute-class-a100.yaml`<br/>`manifests/workloads/llm-batch-inference-job.yaml` |
| **`ai-training-dws-09`** | `us-central1-a` | `ai-training` | `Job/gemma-fine-tuning-job` | Primary DWS training host | `manifests/workloads/gemma-fine-tuning-job.yaml` |

---

## 2. Organization `433637338589` / Project: `gca-gke-test` *(Edge Routing & Analytics Fleet)*

### 🇪🇺 Europe Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`prod-catalog-sync-13`** | `europe-west1-c` *(Belgium)* | `prod-apps` | `Deployment/config-syncer` | EU catalog data replication | `manifests/workloads/config-syncer-service.yaml` |
| **`prod-ha-payments-14`** | `europe-west3-b` *(Frankfurt)* | `prod-payments` | `Deployment/ha-payment-gateway`<br/>`Deployment/payment-session-worker` | European HA payment gateway | `manifests/workloads/ha-payment-gateway-service.yaml` |

### 🌏 Asia-Pacific Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`prod-analytics-store-15`** | `asia-east1-b` *(Taiwan)* | `prod-analytics` | `Deployment/analytics-worker`<br/>`PVC/analytics-shared-pvc` | APAC analytics data ingestion | `manifests/workloads/analytics-worker-service.yaml` |
| **`hpc-batch-compute-17`** | `asia-southeast1-b` *(Singapore)* | `hpc-batch` | `Deployment/hpc-batch-analytics`<br/>`ComputeClass/cpu-hpc-compute-class` | APAC HPC batch simulations | `clusters/hpc-batch-compute-17/compute-class-cpu.yaml`<br/>`manifests/workloads/hpc-batch-analytics-job.yaml` |

### 🇺🇸 Americas Regional Clusters
| Cluster Name | Location | Namespace | Workload(s) & Resource Kind | Business Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`edge-ingress-gateway-06`** | `us-central1-a` | `prod-ingress` | `Deployment/frontend-web-gateway`<br/>`Service/frontend-web-svc`<br/>`Ingress/frontend-web-gateway` | Public SSL edge ingress & CDN | `manifests/workloads/frontend-web-gateway.yaml` |
| **`prod-api-router-07`** | `us-east1-c` / `us-central1-a` | `prod-gateway` | `Deployment/api-routing-proxy` | Global API reverse proxy | `manifests/workloads/api-routing-proxy.yaml` |
| **`prod-auto-scaler-10`** | `us-west1-b` / `us-central1-a` | `prod-workers` | `HPA/queue-worker-hpa`<br/>`Deployment/queue-worker-service` | Dynamic queue autoscaling | `manifests/workloads/queue-worker-service.yaml` |
| **`prod-catalog-sync-13`** | `us-central1-a` | `prod-apps` | `Deployment/config-syncer` | US catalog data synchronization | `manifests/workloads/config-syncer-service.yaml` |
| **`prod-ha-payments-14`** | `us-central1-a` | `prod-payments`<br/>`webhook-system` | `Deployment/ha-payment-gateway`<br/>`Deployment/payment-session-worker`<br/>`Deployment/admission-webhook-server`<br/>`MutatingWebhook/fleet-policy-enforcer` | HA payment gateway & webhook | `manifests/workloads/ha-payment-gateway-service.yaml`<br/>`manifests/workloads/payment-api-gateway.yaml` |
| **`prod-analytics-store-15`** | `us-central1-a` | `prod-analytics` | `Deployment/analytics-worker`<br/>`PVC/analytics-shared-pvc` | Shared analytics storage | `manifests/workloads/analytics-worker-service.yaml` |
| **`hpc-batch-compute-17`** | `us-central1-a` | `hpc-batch` | `Deployment/hpc-batch-analytics`<br/>`ComputeClass/cpu-hpc-compute-class` | CPU-intensive HPC simulations | `clusters/hpc-batch-compute-17/compute-class-cpu.yaml`<br/>`manifests/workloads/hpc-batch-analytics-job.yaml` |

---

## 3. 🖥️ Companion Compute Engine (GCE) Infrastructure (`gce/`)

| Instance / Resource | Zone | Purpose | GitOps Manifest Location |
| :--- | :---: | :--- | :--- |
| **`prod-edge-bastion-gateway`** | `us-central1-a` | Secure jump host & SSH ingress bastion | `gce/prod-edge-bastion-gateway/networking.yaml` |
| **`prod-auth-legacy-vm`** | `us-central1-a` | Legacy authentication bridge service | `gce/prod-auth-legacy-vm/instance.yaml` |
| **`prod-payment-mig-gateway`** | `us-central1-a` | Managed Instance Group for legacy payment routing | `gce/prod-payment-mig-gateway/mig-template.yaml` |
| **`prod-audit-logger-vm`** | `us-central1-a` | Syslog & SIEM audit forwarder | `gce/prod-audit-logger-vm/instance.yaml` |
| **`prod-finops-telemetry-exporter`** | `us-central1-a` | Fleet telemetry & FinOps collector VM | `gce/prod-finops-telemetry-exporter/instance.yaml` |

---

## 4. 🗄️ GCP Shared Infrastructure (`gcp-infrastructure/`)

* **CloudSQL Database Tier**: `gcp-infrastructure/database/cloudsql-instance.yaml`
* **Cloud KMS Keyring & Keys**: `gcp-infrastructure/kms/kms-keyring.yaml`
* **Cloud Storage Buckets**: `gcp-infrastructure/storage/gcs-buckets.yaml`
* **Workload Identity IAM Bindings**: `gcp-infrastructure/iam/workload-identity-bindings.yaml`
* **VPC Networking & Subnets**: `gcp-infrastructure/networking/vpc-network.yaml`
