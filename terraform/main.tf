terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  alias   = "proj2025"
  project = "gca-gke-2025"
  region  = "us-central1"
}

provider "google" {
  alias   = "projtest"
  project = "gca-gke-test"
  region  = "us-central1"
}

provider "google" {
  project = "gca-gke-2025"
  region  = "us-central1"
}

# -------------------------------------------------------------------
# Primary Project Multi-Region Fleet Clusters (gca-gke-2025)
# -------------------------------------------------------------------
module "cluster_prod_core_api_01" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-core-api-01"
  project_id   = "gca-gke-2025"
  region       = "us-central1"
  zone         = "us-central1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_user_auth_02" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-user-auth-02"
  project_id   = "gca-gke-2025"
  region       = "us-central1"
  zone         = "us-central1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_data_pipeline_03" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-data-pipeline-03"
  project_id   = "gca-gke-2025"
  region       = "us-east1"
  zone         = "us-east1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_checkout_04" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-checkout-04"
  project_id   = "gca-gke-2025"
  region       = "us-east4"
  zone         = "us-east4-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_storage_db_05" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-storage-db-05"
  project_id   = "gca-gke-2025"
  region       = "us-west1"
  zone         = "us-west1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_batch_analytics_08" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "batch-analytics-08"
  project_id   = "gca-gke-2025"
  region       = "us-west2"
  zone         = "us-west2-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_ai_training_dws_09" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "ai-training-dws-09"
  project_id   = "gca-gke-2025"
  region       = "europe-west1"
  zone         = "europe-west1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_checkout_gateway_11" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-checkout-gateway-11"
  project_id   = "gca-gke-2025"
  region       = "europe-west3"
  zone         = "europe-west3-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_order_processing_12" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "prod-order-processing-12"
  project_id   = "gca-gke-2025"
  region       = "asia-east1"
  zone         = "asia-east1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_ai_inference_gpu_16" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.proj2025 }
  cluster_name = "ai-inference-gpu-16"
  project_id   = "gca-gke-2025"
  region       = "asia-southeast1"
  zone         = "asia-southeast1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

# -------------------------------------------------------------------
# Secondary Project Multi-Region Fleet Clusters (gca-gke-test)
# -------------------------------------------------------------------
module "cluster_edge_ingress_gateway_06" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "edge-ingress-gateway-06"
  project_id   = "gca-gke-test"
  region       = "us-central1"
  zone         = "us-central1-c"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_api_router_07" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "prod-api-router-07"
  project_id   = "gca-gke-test"
  region       = "us-east1"
  zone         = "us-east1-c"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_auto_scaler_10" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "prod-auto-scaler-10"
  project_id   = "gca-gke-test"
  region       = "us-west1"
  zone         = "us-west1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_catalog_sync_13" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "prod-catalog-sync-13"
  project_id   = "gca-gke-test"
  region       = "europe-west1"
  zone         = "europe-west1-c"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_ha_payments_14" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "prod-ha-payments-14"
  project_id   = "gca-gke-test"
  region       = "europe-west3"
  zone         = "europe-west3-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_prod_analytics_store_15" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "prod-analytics-store-15"
  project_id   = "gca-gke-test"
  region       = "asia-east1"
  zone         = "asia-east1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}

module "cluster_hpc_batch_compute_17" {
  source       = "./modules/gke-cluster"
  providers    = { google = google.projtest }
  cluster_name = "hpc-batch-compute-17"
  project_id   = "gca-gke-test"
  region       = "asia-southeast1"
  zone         = "asia-southeast1-b"
  node_count   = 2
  machine_type = "e2-standard-2"
}
