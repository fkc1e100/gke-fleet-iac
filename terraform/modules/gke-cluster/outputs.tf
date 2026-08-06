output "cluster_name" {
  description = "The name of the provisioned GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE cluster master endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "workload_identity_pool" {
  description = "The GCP Workload Identity Pool for Kubernetes Service Accounts"
  value       = "${var.project_id}.svc.id.goog"
}

output "get_credentials_command" {
  description = "gcloud CLI command to retrieve cluster credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}
