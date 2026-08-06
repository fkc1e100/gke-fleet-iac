terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_2025" {
  type    = string
  default = "gca-gke-2025"
}

variable "project_test" {
  type    = string
  default = "gca-gke-test"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
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

  source       = "./modules/gke-cluster"
  cluster_name = each.value
  project_id   = var.project_2025
  region       = var.region
  zone         = var.zone
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

  source       = "./modules/gke-cluster"
  cluster_name = each.value
  project_id   = var.project_test
  region       = var.region
  zone         = var.zone
  node_count   = 2
  machine_type = "e2-standard-2"
}
# Triggering automated fleet cluster deployment across gca-gke-2025 and gca-gke-test
