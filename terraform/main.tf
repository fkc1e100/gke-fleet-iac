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

# Default provider fallback
provider "google" {
  project = "gca-gke-2025"
  region  = "us-central1"
}

# -------------------------------------------------------------------
# Primary Project Fleet Clusters (gca-gke-2025)
# -------------------------------------------------------------------
module "fleet_clusters_2025" {
  for_each = toset([
    "cluster-01",
    "cluster-02",
    "cluster-03",
    "cluster-04",
    "cluster-05",
    "cluster-08",
    "cluster-09",
    "complex-01",
    "complex-02",
    "complex-06"
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
    "cluster-06",
    "cluster-07",
    "cluster-10",
    "complex-03",
    "complex-04",
    "complex-05",
    "complex-07"
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
