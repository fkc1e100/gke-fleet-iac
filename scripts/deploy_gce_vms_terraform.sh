#!/usr/bin/env bash
set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# -------------------------------------------------------------------
# Automated GCP Auth Check & Project Resolution Wizard
# -------------------------------------------------------------------
ensure_gcp_auth_and_project() {
  echo "=== Checking GCP Authentication ==="
  if ! gcloud auth print-access-token >/dev/null 2>&1; then
    echo "➜ GCP authentication required. Initiating gcloud login..."
    gcloud auth login
    gcloud auth application-default login
  else
    echo "✔ GCP gcloud CLI authenticated."
  fi

  if [ -n "${GCP_PROJECT_ID}" ]; then
    echo "✔ Using GCP_PROJECT_ID from environment: ${GCP_PROJECT_ID}"
    return
  fi

  DETECTED_PROJ="$(gcloud config get-value project 2>/dev/null || echo "")"

  if [ -t 0 ]; then
    echo ""
    echo "=== GCP Project Setup ==="
    if [ -n "${DETECTED_PROJ}" ]; then
      read -p "Detected active GCP Project '${DETECTED_PROJ}'. Use this project? [Y/n]: " choice
      case "$choice" in
        [nN][oO]|[nN])
          read -p "Enter target GCP Project ID: " INPUT_PROJ
          export GCP_PROJECT_ID="${INPUT_PROJ}"
          ;;
        *)
          export GCP_PROJECT_ID="${DETECTED_PROJ}"
          ;;
      esac
    else
      read -p "Enter target GCP Project ID: " INPUT_PROJ
      export GCP_PROJECT_ID="${INPUT_PROJ}"
    fi
  else
    export GCP_PROJECT_ID="${DETECTED_PROJ:-gca-gke-2025}"
  fi

  gcloud config set project "${GCP_PROJECT_ID}" >/dev/null 2>&1 || true
  echo "✔ Active GCP Project set to: ${GCP_PROJECT_ID}"
}

ensure_gcp_auth_and_project

echo "============================================================"
echo " Deploying GCE VM Compute Infrastructure via Terraform IaC"
echo " Target GCP Project: ${GCP_PROJECT_ID}"
echo "============================================================"

cd "${REPO_ROOT}/gce/terraform"
terraform init
terraform apply -auto-approve -var="project_id=${GCP_PROJECT_ID}"

echo "============================================================"
echo " ✔ Terraform GCE VM Deployment Complete."
echo "============================================================"
