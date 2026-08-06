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
# Primary Project Fleet Clusters (gca-gke-2025)
# -------------------------------------------------------------------
module "fleet_clusters_2025" {
  for_each = toset([
    "prod-core-api-01",
    "prod-user-auth-02",
    "prod-data-pipeline-03",
    "prod-checkout-04",
    "prod-storage-db-05",
    "batch-analytics-08",
    "ai-training-dws-09",
    "prod-checkout-gateway-11",
    "prod-order-processing-12",
    "ai-inference-gpu-16"
  ])

  providers = {
    google = google.proj2025
  }

  source       = "./modules/gke-cluster"
  cluster_name = each.value
  project_id   = "gca-gke-2025"
  region       = "us-central1"
  zone         = "us-central1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}

# -------------------------------------------------------------------
# Secondary Project Fleet Clusters (gca-gke-test)
# -------------------------------------------------------------------
module "fleet_clusters_test" {
  for_each = toset([
    "edge-ingress-gateway-06",
    "prod-api-router-07",
    "prod-auto-scaler-10",
    "prod-catalog-sync-13",
    "prod-ha-payments-14",
    "prod-analytics-store-15",
    "hpc-batch-compute-17"
  ])

  providers = {
    google = google.projtest
  }

  source       = "./modules/gke-cluster"
  cluster_name = each.value
  project_id   = "gca-gke-test"
  region       = "us-central1"
  zone         = "us-central1-a"
  node_count   = 2
  machine_type = "e2-standard-2"
}
