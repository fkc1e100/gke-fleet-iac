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

variable "network" {
  type        = string
  description = "VPC Network Name"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "Subnet Name"
  default     = "default"
}

variable "machine_type" {
  type        = string
  description = "Default Node Pool Machine Type"
  default     = "e2-standard-2"
}

variable "node_count" {
  type        = number
  description = "Default Node Pool Initial Count"
  default     = 2
}

variable "release_channel" {
  type        = string
  description = "GKE Release Channel (REGULAR, RAPID, STABLE)"
  default     = "REGULAR"
}

variable "node_labels" {
  type        = map(string)
  description = "Labels to apply to node pool"
  default = {
    environment = "production"
    managed-by  = "terraform"
  }
}

variable "enable_spot_gpu_pool" {
  type        = bool
  description = "Whether to provision a secondary Spot GPU autoscaling pool"
  default     = false
}

variable "gpu_machine_type" {
  type        = string
  description = "Machine type for GPU pool"
  default     = "a2-ultragpu-1g"
}

variable "gpu_type" {
  type        = string
  description = "GPU accelerator type"
  default     = "nvidia-tesla-a100"
}

variable "gpu_count" {
  type        = number
  description = "GPUs per node"
  default     = 1
}

variable "max_gpu_nodes" {
  type        = number
  description = "Max nodes for GPU pool autoscaling"
  default     = 10
}
