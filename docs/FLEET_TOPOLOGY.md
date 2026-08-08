# Global Fleet Topology & Workload Mapping

This document provides a comprehensive mapping of the **Organization ➔ Project ➔ Region ➔ Cluster ➔ Workload** hierarchy managed by this repository across Google Cloud.

---

## 🏢 Multi-Organization Architecture & M&A Context

This infrastructure landscape reflects the real-world **merger of two global e-commerce and retail technology enterprises**. Rather than undertaking an immediate, high-risk single-organization cloud migration, the platform engineering team adopted a unified **GitOps repository (`gke-fleet-iac`)** and **autonomous harness (`kube-agents`)** to manage both historical cloud environments under unified governance:

- **🏢 `gkedemos.joonix.net` (Organization ID: `926317919369`)**:
  - **Role**: Primary acquiring enterprise platform.
  - **Project**: **`gca-gke-2025`** (`764460891170`).
  - **Workloads**: Core payment transactional engines, centralized user identity & authentication (JWT), transactional databases, and cutting-edge generative AI model fine-tuning / GPU inference (DWS / NVIDIA A100s).
- **🏢 `google.com` (Organization ID: `433637338589`)**:
  - **Role**: Acquired global retail brand's historical cloud infrastructure.
  - **Project**: **`gca-gke-test`** (`825476174734`) _(nested under the `dev_projects` folder tree)_.
  - **Workloads**: High-throughput public edge ingress routing, multi-region catalog synchronization, European high-availability payment fallback gateways, and CPU-intensive HPC batch compute.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffffff', 'primaryBorderColor': '#1a73e8', 'primaryTextColor': '#202124', 'lineColor': '#5f6368', 'fontFamily': 'Inter, -apple-system, sans-serif', 'fontSize': '14px' }}}%%
flowchart LR
    subgraph ORG1["🏢 Primary Enterprise: gkedemos.joonix.net (ID: 926317919369)"]
        P1["📁 Host Project: gca-gke-2025<br>• Core Payment Transactions<br>• User Identity & Auth (JWT)<br>• AI Training & GPU Inference<br>• CloudSQL & PostgreSQL DBs"]
    end

    subgraph ORG2["🏢 Acquired Retail Org: google.com (ID: 433637338589)"]
        FOLDER["📂 dev_projects (folders/657923791383)"]
        P2["📁 Fleet Project: gca-gke-test<br>• Public Edge Ingress & CDN<br>• Global Catalog Sync<br>• HA Payment Gateway Fallback<br>• CPU HPC Batch Simulations"]
        FOLDER --> P2
    end

    GITOPS["🐙 GitOps Monorepo: gke-fleet-iac<br>• ArgoCD Workload Apps<br>• Terraform Multi-Cluster IaC<br>• Gatekeeper Guardrails"]
    AGENT["🤖 Platform Agent (kube-agents)<br>• Workload Identity Governance<br>• Multi-Project Security Audit"]

    GITOPS ==>|Reconciles Manifests| P1
    GITOPS ==>|Reconciles Manifests| P2
    AGENT -.->|Audits & Proposes PRs| P1
    AGENT -.->|Audits & Proposes PRs| P2
    P2 <==>|Private Service Connect & mTLS| P1

    classDef host fill:#e8f0fe,stroke:#1a73e8,stroke-width:2px,color:#174ea6,font-weight:bold;
    classDef test fill:#e6f4ea,stroke:#137333,stroke-width:2px,color:#0d652d,font-weight:bold;
    classDef tool fill:#fef7e0,stroke:#f29900,stroke-width:1.5px,color:#b06000;

    class P1 host;
    class P2 test;
    class GITOPS,AGENT tool;
```

---

## 1. Organization `gkedemos.joonix.net` (`926317919369`) / Project: `gca-gke-2025`

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffffff', 'primaryBorderColor': '#1a73e8', 'primaryTextColor': '#202124', 'lineColor': '#5f6368', 'fontFamily': 'Inter, -apple-system, sans-serif', 'fontSize': '13px' }}}%%
flowchart TD
    P1["📁 gca-gke-2025: Core Platform & AI Workloads"]

    subgraph EU["🇪🇺 Europe Regional Clusters"]
        C_DWS_EU["☸️ ai-training-dws-09 (europe-west1-b)<br>📦 gemma-fine-tuning-job (DWS Worker)"]
        C_CHKG_EU["☸️ prod-checkout-gateway-11 (europe-west3-a)<br>📦 checkout-backend (EU Routing Gateway)"]
    end

    subgraph APAC["🌏 Asia-Pacific Regional Clusters"]
        C_ORD_APAC["☸️ prod-order-processing-12 (asia-east1-a)<br>📦 config-syncer (Order Sync & Workflow)"]
        C_INF_APAC["☸️ ai-inference-gpu-16 (asia-southeast1-a)<br>📦 llm-batch-inference (GPU LLM Inference)"]
    end

    subgraph US["🇺🇸 Americas Regional Clusters"]
        C_CORE_US["☸️ prod-core-api-01 (us-central1-a)<br>📦 payment-processor (Core API)"]
        C_AUTH_US["☸️ prod-user-auth-02 (us-central1-a)<br>📦 user-auth-service (Identity & JWT)"]
        C_CHK_US["☸️ prod-checkout-04 (us-east4-a / us-central1-a)<br>📦 checkout-backend-api / db-redis"]
        C_PIPE_US["☸️ prod-data-pipeline-03 (us-east1-b / us-central1-a)<br>📦 memory-cache / queue-worker"]
        C_DB_US["☸️ prod-storage-db-05 (us-west1-a / us-central1-a)<br>📦 stateful-postgres-db (Database Tier)"]
        C_BATCH_US["☸️ batch-analytics-08 (us-west2-a / us-central1-a)<br>📦 batch-report-worker (Reporting ETL)"]
        C_INF_US["☸️ ai-inference-gpu-16 (us-central1-a)<br>📦 llm-batch-inference (A100 GPU Class)"]
        C_DWS_US["☸️ ai-training-dws-09 (us-central1-a)<br>📦 gemma-fine-tuning-job (Primary Host)"]
    end

    P1 --> EU
    P1 --> APAC
    P1 --> US

    classDef host fill:#e8f0fe,stroke:#1a73e8,stroke-width:2px,color:#174ea6,font-weight:bold;
    classDef aiNode fill:#f3e8fd,stroke:#9334e8,stroke-width:1.5px,color:#681da8;
    classDef payNode fill:#fef7e0,stroke:#f29900,stroke-width:1.5px,color:#b06000;
    classDef dataNode fill:#e0f2fe,stroke:#0284c7,stroke-width:1.5px,color:#0369a1;

    class P1 host;
    class C_DWS_EU,C_INF_APAC,C_INF_US,C_DWS_US aiNode;
    class C_CORE_US,C_CHK_US,C_CHKG_EU payNode;
    class C_PIPE_US,C_DB_US,C_BATCH_US,C_AUTH_US,C_ORD_APAC dataNode;
```

### 🇪🇺 Europe Clusters (`gca-gke-2025`)

| Cluster Name                   |            Location            | Namespace       | Workload(s) & Resource Kind   | Business Purpose            | GitOps Manifest Location                            |
| :----------------------------- | :----------------------------: | :-------------- | :---------------------------- | :-------------------------- | :-------------------------------------------------- |
| **`ai-training-dws-09`**       |  `europe-west1-b` _(Belgium)_  | `ai-training`   | `Job/gemma-fine-tuning-job`   | DWS Gemma model training    | `manifests/workloads/gemma-fine-tuning-job.yaml`    |
| **`prod-checkout-gateway-11`** | `europe-west3-a` _(Frankfurt)_ | `prod-checkout` | `Deployment/checkout-backend` | EU checkout routing gateway | `manifests/workloads/checkout-backend-service.yaml` |

### 🌏 Asia-Pacific Clusters (`gca-gke-2025`)

| Cluster Name                   |             Location              | Namespace      | Workload(s) & Resource Kind                                   | Business Purpose             | GitOps Manifest Location                           |
| :----------------------------- | :-------------------------------: | :------------- | :------------------------------------------------------------ | :--------------------------- | :------------------------------------------------- |
| **`prod-order-processing-12`** |     `asia-east1-a` _(Taiwan)_     | `prod-apps`    | `Deployment/config-syncer`<br/>`ServiceAccount/restricted-sa` | APAC order lifecycle sync    | `manifests/workloads/config-syncer-service.yaml`   |
| **`ai-inference-gpu-16`**      | `asia-southeast1-a` _(Singapore)_ | `ai-inference` | `Deployment/llm-batch-inference`                              | APAC GPU LLM batch inference | `manifests/workloads/llm-batch-inference-job.yaml` |

### 🇺🇸 Americas Clusters (`gca-gke-2025`)

| Cluster Name                |            Location            | Namespace                         | Workload(s) & Resource Kind                                             | Business Purpose                | GitOps Manifest Location                                                                                      |
| :-------------------------- | :----------------------------: | :-------------------------------- | :---------------------------------------------------------------------- | :------------------------------ | :------------------------------------------------------------------------------------------------------------ |
| **`prod-core-api-01`**      |        `us-central1-a`         | `prod-payments`                   | `Deployment/payment-processor`                                          | Core payment transactions       | `manifests/workloads/payment-processor.yaml`                                                                  |
| **`prod-user-auth-02`**     |        `us-central1-a`         | `prod-auth`                       | `Deployment/user-auth-service`                                          | User identity & JWT auth tokens | `manifests/workloads/user-auth-service.yaml`                                                                  |
| **`prod-checkout-04`**      | `us-east4-a` / `us-central1-a` | `prod-checkout`                   | `Deployment/checkout-backend-api`<br/>`StatefulSet/db-redis`            | E-commerce checkout backend     | `manifests/workloads/checkout-backend-api.yaml`<br/>`manifests/workloads/checkout-backend-service.yaml`       |
| **`prod-data-pipeline-03`** | `us-east1-b` / `us-central1-a` | `prod-caching`<br/>`prod-workers` | `Deployment/memory-cache-service`<br/>`Deployment/queue-worker-service` | Redis caching & async queues    | `manifests/workloads/memory-cache-service.yaml`<br/>`manifests/workloads/queue-worker-service.yaml`           |
| **`prod-storage-db-05`**    | `us-west1-a` / `us-central1-a` | `prod-databases`                  | `Deployment/stateful-postgres-db`<br/>`PVC/postgres-data-pvc`           | Relational database tier        | `manifests/workloads/stateful-postgres-db.yaml`                                                               |
| **`batch-analytics-08`**    | `us-west2-a` / `us-central1-a` | `batch-processing`                | `Deployment/batch-report-worker-processor`                              | Scheduled analytical ETL        | `manifests/workloads/batch-report-worker.yaml`                                                                |
| **`ai-inference-gpu-16`**   |        `us-central1-a`         | `ai-inference`                    | `Deployment/llm-batch-inference`<br/>`ComputeClass/a100-gpu-class`      | High-throughput GPU inference   | `clusters/ai-inference-gpu-16/compute-class-a100.yaml`<br/>`manifests/workloads/llm-batch-inference-job.yaml` |
| **`ai-training-dws-09`**    |        `us-central1-a`         | `ai-training`                     | `Job/gemma-fine-tuning-job`                                             | Primary DWS training host       | `manifests/workloads/gemma-fine-tuning-job.yaml`                                                              |

---

## 2. Organization `google.com` (`433637338589`) / Project: `gca-gke-test`

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffffff', 'primaryBorderColor': '#137333', 'primaryTextColor': '#202124', 'lineColor': '#5f6368', 'fontFamily': 'Inter, -apple-system, sans-serif', 'fontSize': '13px' }}}%%
flowchart TD
    P2["📁 gca-gke-test: Global Edge Routing, Analytics & HA Fleet"]

    subgraph EU2["🇪🇺 Europe Regional Clusters"]
        T_CAT_EU["☸️ prod-catalog-sync-13 (europe-west1-c)<br>📦 config-syncer (EU Catalog Sync)"]
        T_PAY_EU["☸️ prod-ha-payments-14 (europe-west3-b)<br>📦 ha-payment-gateway (EU Fallback)"]
    end

    subgraph APAC2["🌏 Asia-Pacific Regional Clusters"]
        T_STORE_APAC["☸️ prod-analytics-store-15 (asia-east1-b)<br>📦 analytics-worker (Shared PVC)"]
        T_HPC_APAC["☸️ hpc-batch-compute-17 (asia-southeast1-b)<br>📦 hpc-batch-analytics (HPC Simulations)"]
    end

    subgraph US2["🇺🇸 Americas Regional Clusters"]
        T_ING_US["☸️ edge-ingress-gateway-06 (us-central1-a)<br>📦 frontend-web-gateway (Public SSL Ingress)"]
        T_ROUT_US["☸️ prod-api-router-07 (us-east1-c / us-central1-a)<br>📦 api-routing-proxy (Global API Router)"]
        T_AUTO_US["☸️ prod-auto-scaler-10 (us-west1-b / us-central1-a)<br>📦 queue-worker-hpa (Autoscaler Testing)"]
        T_CAT_US["☸️ prod-catalog-sync-13 (us-central1-a)<br>📦 config-syncer (US Catalog Sync)"]
        T_PAY_US["☸️ prod-ha-payments-14 (us-central1-a)<br>📦 ha-payment-gateway / admission-webhook"]
        T_STORE_US["☸️ prod-analytics-store-15 (us-central1-a)<br>📦 analytics-worker (Analytics Store)"]
        T_HPC_US["☸️ hpc-batch-compute-17 (us-central1-a)<br>📦 hpc-batch-analytics (CPU ComputeClass)"]
    end

    P2 --> EU2
    P2 --> APAC2
    P2 --> US2

    classDef test fill:#e6f4ea,stroke:#137333,stroke-width:2px,color:#0d652d,font-weight:bold;
    classDef edgeNode fill:#e0f2fe,stroke:#0284c7,stroke-width:1.5px,color:#0369a1;
    classDef payNode fill:#fef7e0,stroke:#f29900,stroke-width:1.5px,color:#b06000;
    classDef hpcNode fill:#f3e8fd,stroke:#9334e8,stroke-width:1.5px,color:#681da8;

    class P2 test;
    class T_ING_US,T_ROUT_US,T_AUTO_US,T_CAT_EU,T_CAT_US edgeNode;
    class T_PAY_EU,T_PAY_US payNode;
    class T_STORE_APAC,T_STORE_US,T_HPC_APAC,T_HPC_US hpcNode;
```

### 🇪🇺 Europe Clusters (`gca-gke-test`)

| Cluster Name               |            Location            | Namespace       | Workload(s) & Resource Kind                                             | Business Purpose            | GitOps Manifest Location                              |
| :------------------------- | :----------------------------: | :-------------- | :---------------------------------------------------------------------- | :-------------------------- | :---------------------------------------------------- |
| **`prod-catalog-sync-13`** |  `europe-west1-c` _(Belgium)_  | `prod-apps`     | `Deployment/config-syncer`                                              | EU catalog data replication | `manifests/workloads/config-syncer-service.yaml`      |
| **`prod-ha-payments-14`**  | `europe-west3-b` _(Frankfurt)_ | `prod-payments` | `Deployment/ha-payment-gateway`<br/>`Deployment/payment-session-worker` | European HA payment gateway | `manifests/workloads/ha-payment-gateway-service.yaml` |

### 🌏 Asia-Pacific Clusters (`gca-gke-test`)

| Cluster Name                  |             Location              | Namespace        | Workload(s) & Resource Kind                                               | Business Purpose              | GitOps Manifest Location                                                                                      |
| :---------------------------- | :-------------------------------: | :--------------- | :------------------------------------------------------------------------ | :---------------------------- | :------------------------------------------------------------------------------------------------------------ |
| **`prod-analytics-store-15`** |     `asia-east1-b` _(Taiwan)_     | `prod-analytics` | `Deployment/analytics-worker`<br/>`PVC/analytics-shared-pvc`              | APAC analytics data ingestion | `manifests/workloads/analytics-worker-service.yaml`                                                           |
| **`hpc-batch-compute-17`**    | `asia-southeast1-b` _(Singapore)_ | `hpc-batch`      | `Deployment/hpc-batch-analytics`<br/>`ComputeClass/cpu-hpc-compute-class` | APAC HPC batch simulations    | `clusters/hpc-batch-compute-17/compute-class-cpu.yaml`<br/>`manifests/workloads/hpc-batch-analytics-job.yaml` |

### 🇺🇸 Americas Clusters (`gca-gke-test`)

| Cluster Name                  |            Location            | Namespace                            | Workload(s) & Resource Kind                                                                                                                                   | Business Purpose                | GitOps Manifest Location                                                                                      |
| :---------------------------- | :----------------------------: | :----------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------ | :------------------------------------------------------------------------------------------------------------ |
| **`edge-ingress-gateway-06`** |        `us-central1-a`         | `prod-ingress`                       | `Deployment/frontend-web-gateway`<br/>`Service/frontend-web-svc`<br/>`Ingress/frontend-web-gateway`                                                           | Public SSL edge ingress & CDN   | `manifests/workloads/frontend-web-gateway.yaml`                                                               |
| **`prod-api-router-07`**      | `us-east1-c` / `us-central1-a` | `prod-gateway`                       | `Deployment/api-routing-proxy`                                                                                                                                | Global API reverse proxy        | `manifests/workloads/api-routing-proxy.yaml`                                                                  |
| **`prod-auto-scaler-10`**     | `us-west1-b` / `us-central1-a` | `prod-workers`                       | `HPA/queue-worker-hpa`<br/>`Deployment/queue-worker-service`                                                                                                  | Dynamic queue autoscaling       | `manifests/workloads/queue-worker-service.yaml`                                                               |
| **`prod-catalog-sync-13`**    |        `us-central1-a`         | `prod-apps`                          | `Deployment/config-syncer`                                                                                                                                    | US catalog data synchronization | `manifests/workloads/config-syncer-service.yaml`                                                              |
| **`prod-ha-payments-14`**     |        `us-central1-a`         | `prod-payments`<br/>`webhook-system` | `Deployment/ha-payment-gateway`<br/>`Deployment/payment-session-worker`<br/>`Deployment/admission-webhook-server`<br/>`MutatingWebhook/fleet-policy-enforcer` | HA payment gateway & webhook    | `manifests/workloads/ha-payment-gateway-service.yaml`<br/>`manifests/workloads/payment-api-gateway.yaml`      |
| **`prod-analytics-store-15`** |        `us-central1-a`         | `prod-analytics`                     | `Deployment/analytics-worker`<br/>`PVC/analytics-shared-pvc`                                                                                                  | Shared analytics storage        | `manifests/workloads/analytics-worker-service.yaml`                                                           |
| **`hpc-batch-compute-17`**    |        `us-central1-a`         | `hpc-batch`                          | `Deployment/hpc-batch-analytics`<br/>`ComputeClass/cpu-hpc-compute-class`                                                                                     | CPU-intensive HPC simulations   | `clusters/hpc-batch-compute-17/compute-class-cpu.yaml`<br/>`manifests/workloads/hpc-batch-analytics-job.yaml` |

---

## 3. 🖥️ Companion Compute Engine (GCE) Infrastructure (`gce/`)

| Instance / Resource                  |      Zone       | Purpose                                           | GitOps Manifest Location                           |
| :----------------------------------- | :-------------: | :------------------------------------------------ | :------------------------------------------------- |
| **`prod-edge-bastion-gateway`**      | `us-central1-a` | Secure jump host & SSH ingress bastion            | `gce/prod-edge-bastion-gateway/networking.yaml`    |
| **`prod-auth-legacy-vm`**            | `us-central1-a` | Legacy authentication bridge service              | `gce/prod-auth-legacy-vm/instance.yaml`            |
| **`prod-payment-mig-gateway`**       | `us-central1-a` | Managed Instance Group for legacy payment routing | `gce/prod-payment-mig-gateway/mig-template.yaml`   |
| **`prod-audit-logger-vm`**           | `us-central1-a` | Syslog & SIEM audit forwarder                     | `gce/prod-audit-logger-vm/instance.yaml`           |
| **`prod-finops-telemetry-exporter`** | `us-central1-a` | Fleet telemetry & FinOps collector VM             | `gce/prod-finops-telemetry-exporter/instance.yaml` |

---

## 4. 🗄️ GCP Shared Infrastructure (`gcp-infrastructure/`)

- **CloudSQL Database Tier**: `gcp-infrastructure/database/cloudsql-instance.yaml`
- **Cloud KMS Keyring & Keys**: `gcp-infrastructure/kms/kms-keyring.yaml`
- **Cloud Storage Buckets**: `gcp-infrastructure/storage/gcs-buckets.yaml`
- **Workload Identity IAM Bindings**: `gcp-infrastructure/iam/workload-identity-bindings.yaml`
- **VPC Networking & Subnets**: `gcp-infrastructure/networking/vpc-network.yaml`

---

## ❓ Frequently Asked Questions (Architecture & Topology FAQ)

### Q1: Why are our clusters split across two completely separate Google Cloud Organizations?

**Context & Narrative**: Our retail enterprise represents the strategic merger of two technology platforms. `gkedemos.joonix.net` was the acquiring platform's core infrastructure host (`gca-gke-2025`), while `google.com` housed the acquired company's global edge network and catalog fleet (`gca-gke-test`). Rather than risking transactional outages with a monolithic organization migration, we unified both environments using this single GitOps repository (`gke-fleet-iac`) and cross-org Workload Identity trust governed by `kube-agents`.

### Q2: How do microservices communicate across projects and organizations?

Microservices communicate across projects using **Google Cloud Private Service Connect (PSC)** endpoints, **Cloud Armor protected HTTPRoute / Ingress Gateways**, and VPC internal load balancers (`payment-ilb-service`). Edge clusters in `gca-gke-test` terminate external TLS traffic and forward sanitized requests to core microservices in `gca-gke-2025` over authenticated mTLS tunnels.

### Q3: Why are certain cluster names repeated across multiple regions (e.g. `prod-checkout-04`)?

Critical transactional tiers utilize an **Active-Active Multi-Region Resiliency Pattern**. Running paired clusters across US (`us-central1-a`, `us-east4-a`) and Europe (`europe-west3-a`) ensures sub-50ms checkout latency for local shoppers and seamless automated traffic failover during regional maintenance windows. For AI clusters (`ai-training-dws-09`), geo-distribution enables opportunistic scheduling across regional Dynamic Workload Scheduler (DWS) GPU/TPU quota pools.

### Q4: How does GitOps route workloads to the correct cluster tier?

Workloads in `manifests/workloads/` utilize Kubernetes **ComputeClasses** (`a100-gpu-class`, `cpu-hpc-compute-class`) and GKE Fleet Hub cluster selectors. When ArgoCD reconciles manifests, cluster-affinity constraints ensure AI models land exclusively on GPU node pools while payment gateways deploy to PCI-DSS hardened clusters.

### Q5: What is the persistence source of truth: CloudSQL or in-cluster PostgreSQL?

**CloudSQL (`gcp-infrastructure/database/cloudsql-instance.yaml`)** is the primary, ACID-compliant system of record for financial transactions and account balances. In-cluster PostgreSQL (`stateful-postgres-db`) and Redis (`db-redis`) instances serve as regional read-replicas, caching layers, and session state stores to minimize cross-region database latency.

### Q6: Why are Compute Engine (GCE) VMs included in this Kubernetes repository?

This repository enforces a **Hybrid Modernization Architecture**. Certain critical enterprise legacy components — such as the PCI-DSS certified HSM payment gateway (`prod-payment-mig-gateway`) and the legacy LDAP authentication bridge (`prod-auth-legacy-vm`) — run on managed Compute Engine VMs. Keeping their Terraform and networking definitions alongside GKE ensures changes to upstream APIs do not break downstream VM dependencies.

### Q7: How does `kube-agents` audit both organizations without credential leakage?

The central Platform Agent runs on `platform-agent` in `gca-gke-2025` using Google Cloud Workload Identity. Secondary projects (like `gca-gke-test`) grant least-privilege telemetry and audit viewer roles (`roles/container.viewer`, `roles/logging.viewer`, `roles/monitoring.viewer`) to the Platform Agent's Google Service Account, eliminating long-lived service account keys across organization boundaries.
