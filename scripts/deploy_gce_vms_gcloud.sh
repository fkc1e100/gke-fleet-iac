#!/usr/bin/env bash
set -eo pipefail

echo "============================================================"
echo " Deploying / Resetting GCE VM Environments via gcloud CLI"
echo "============================================================"

# Dynamic GCP Project resolution
DEFAULT_PROJECT="$(gcloud config get-value project 2>/dev/null || echo "gca-gke-2025")"
PROJ_2025="${GCP_PROJECT_2025:-${GCP_PROJECT_ID:-$DEFAULT_PROJECT}}"
PROJ_TEST="${GCP_PROJECT_TEST:-${GCP_PROJECT_ID:-$DEFAULT_PROJECT}}"
ZONE="us-central1-a"

# Scenario 1: prod-legacy-auth-vm (Startup Script Package Egress Failure)
echo "=== Deploying Scenario GCE-01: prod-legacy-auth-vm ==="
gcloud compute instances create prod-legacy-auth-vm \
  --project="$PROJ_2025" \
  --zone="$ZONE" \
  --machine-type=e2-standard-2 \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y python3-pip
pip3 install non-existent-python-package-v99 || exit 1
python3 -m http.server 8080' || true

# Scenario 2: prod-audit-logger-vm (Boot Disk 100% Full Journal Lock)
echo "=== Deploying Scenario GCE-02: prod-audit-logger-vm ==="
gcloud compute instances create prod-audit-logger-vm \
  --project="$PROJ_2025" \
  --zone="$ZONE" \
  --machine-type=e2-standard-4 \
  --boot-disk-size=10GB \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --metadata=startup-script='#!/bin/bash
dd if=/dev/zero of=/var/log/audit-spool.log bs=1M count=9500
systemctl restart systemd-journald' || true

# Scenario 3: prod-mig-payment-gateway (MIG Autohealing IAM Lockout)
echo "=== Deploying Scenario GCE-03: prod-mig-payment-gateway ==="
gcloud compute instance-templates create prod-mig-payment-template \
  --project="$PROJ_2025" \
  --machine-type=e2-standard-4 \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --metadata=startup-script='#!/bin/bash
gcloud secrets versions access latest --secret="payment-kms-key" || { echo "FATAL: IAM 403 Permission Denied"; exit 1; }
python3 -m http.server 8080' || true

gcloud compute instance-groups managed create prod-mig-payment-gateway \
  --project="$PROJ_2025" \
  --zone="$ZONE" \
  --template=prod-mig-payment-template \
  --size=3 || true

# Scenario 4: prod-edge-bastion-vm (VPC Firewall Deny & Blackhole Route)
echo "=== Deploying Scenario GCE-04: prod-edge-bastion-vm ==="
gcloud compute firewall-rules create block-bastion-ingress \
  --project="$PROJ_TEST" \
  --action=DENY \
  --rules=tcp:22,tcp:443 \
  --direction=INGRESS \
  --priority=1000 || true

gcloud compute instances create prod-edge-bastion-vm \
  --project="$PROJ_TEST" \
  --zone="$ZONE" \
  --machine-type=e2-standard-2 \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud || true

# Scenario 5: prod-finops-exporter-vm (Ops Agent Telemetry & IAM Lockout)
echo "=== Deploying Scenario GCE-05: prod-finops-exporter-vm ==="
gcloud compute instances create prod-finops-exporter-vm \
  --project="$PROJ_2025" \
  --zone="$ZONE" \
  --machine-type=e2-standard-4 \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --metadata=startup-script='#!/bin/bash
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
systemctl restart google-cloud-ops-agent' || true

echo "============================================================"
echo " GCE VM Deployment Complete."
echo "============================================================"
