module "gke_cluster" {
  source = "../../../terraform/modules/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  zone         = var.zone
  machine_type = var.machine_type
  node_count   = var.node_count
}
