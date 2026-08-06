variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "cluster_name" {
  type        = string
  description = "GKE Cluster Name"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  description = "GCE Machine Type"
  default     = "e2-standard-2"
}

variable "node_count" {
  type        = number
  description = "Initial Node Count per Zone"
  default     = 2
}
