variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "instance_name" {
  type        = string
  description = "GCE Instance Name"
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "GCE Machine Type"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone"
}

variable "image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
  description = "Boot disk image family or name"
}

variable "disk_size" {
  type        = number
  default     = 20
  description = "Boot disk size in GB"
}

variable "network" {
  type        = string
  default     = "default"
  description = "VPC Network"
}

variable "startup_script" {
  type        = string
  default     = ""
  description = "Bash startup script metadata"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource FinOps labels"
}
