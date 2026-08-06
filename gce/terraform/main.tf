terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "gca-gke-2025"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

provider "google" {
  project = var.project_id
  zone    = var.zone
}

# 1. prod-auth-legacy-vm (Simple: Package failure without egress NAT)
module "prod_auth_legacy_vm" {
  source         = "../../terraform/modules/gce-instance"
  project_id     = var.project_id
  zone           = var.zone
  instance_name  = "prod-legacy-auth-vm"
  machine_type   = "e2-standard-2"
  startup_script = "pip3 install non-existent-python-package-v99"
  labels = {
    cost-center = "finops-auth-202"
    owner       = "security-team"
  }
}

# 2. prod-audit-logger-vm (Simple: Boot disk 100% full log spooling)
module "prod_audit_logger_vm" {
  source         = "../../terraform/modules/gce-instance"
  project_id     = var.project_id
  zone           = var.zone
  instance_name  = "prod-audit-logger-vm"
  machine_type   = "e2-standard-2"
  disk_size      = 10
  startup_script = "dd if=/dev/urandom of=/var/log/audit-spool.log bs=1M count=10240"
  labels = {
    cost-center = "finops-analytics-707"
    owner       = "data-team"
  }
}

# 3. prod-finops-telemetry-exporter (Complex: Ops Agent IAM LogWriter lockout)
module "prod_finops_exporter_vm" {
  source         = "../../terraform/modules/gce-instance"
  project_id     = var.project_id
  zone           = var.zone
  instance_name  = "prod-finops-exporter-vm"
  machine_type   = "e2-standard-2"
  startup_script = "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh && bash add-google-cloud-ops-agent-repo.sh --also-install"
  labels = {
    cost-center = "finops-analytics-707"
    owner       = "finops-team"
  }
}
