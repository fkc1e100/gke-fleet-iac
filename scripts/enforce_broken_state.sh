#!/usr/bin/env bash
set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_gcp_auth_and_project() {
  echo "=== Checking GCP Authentication ==="
  if ! gcloud auth print-access-token >/dev/null 2>&1; then
    echo "➜ GCP authentication required. Initiating gcloud login..."
    gcloud auth login
    gcloud auth application-default login
  else
    echo "✔ GCP gcloud CLI authenticated."
  fi

  export GCP_PROJECT_2025="${GCP_PROJECT_2025:-gca-gke-2025}"
  export GCP_PROJECT_TEST="${GCP_PROJECT_TEST:-gca-gke-test}"
  export GCP_PROJECT_ID="${GCP_PROJECT_2025}"
}

ensure_gcp_auth_and_project

echo "============================================================"
echo " Starting Fleet Reset to Canonical Evaluation State"
echo " Primary Project: ${GCP_PROJECT_2025}"
echo " Secondary Project: ${GCP_PROJECT_TEST}"
echo "============================================================"

# -------------------------------------------------------------------
# 1. Enforce GKE Fleet Workloads
# -------------------------------------------------------------------
declare -A CLUSTER_DIRS=(
  ["prod-core-api-01"]="${GCP_PROJECT_2025}:us-central1-a:prod-core-api-01"
  ["prod-user-auth-02"]="${GCP_PROJECT_2025}:us-central1-a:prod-user-auth-02"
  ["prod-data-pipeline-03"]="${GCP_PROJECT_2025}:us-east1-b:prod-data-pipeline-03"
  ["prod-checkout-04"]="${GCP_PROJECT_2025}:us-east4-a:prod-checkout-04"
  ["prod-storage-db-05"]="${GCP_PROJECT_2025}:us-west1-a:prod-storage-db-05"
  ["edge-ingress-gateway-06"]="${GCP_PROJECT_TEST}:us-central1-a:edge-ingress-gateway-06"
  ["prod-api-router-07"]="${GCP_PROJECT_TEST}:us-east1-c:prod-api-router-07"
  ["batch-analytics-08"]="${GCP_PROJECT_2025}:us-west2-a:batch-analytics-08"
  ["ai-training-dws-09"]="${GCP_PROJECT_2025}:europe-west1-b:ai-training-dws-09"
  ["prod-auto-scaler-10"]="${GCP_PROJECT_TEST}:us-west1-b:prod-auto-scaler-10"
  ["prod-checkout-gateway-11"]="${GCP_PROJECT_2025}:europe-west3-a:prod-checkout-gateway-11"
  ["prod-order-processing-12"]="${GCP_PROJECT_2025}:asia-east1-a:prod-order-processing-12"
  ["prod-catalog-sync-13"]="${GCP_PROJECT_TEST}:europe-west1-c:prod-catalog-sync-13"
  ["prod-ha-payments-14"]="${GCP_PROJECT_TEST}:europe-west3-b:prod-ha-payments-14"
  ["prod-analytics-store-15"]="${GCP_PROJECT_TEST}:asia-east1-b:prod-analytics-store-15"
  ["ai-inference-gpu-16"]="${GCP_PROJECT_2025}:asia-southeast1-a:ai-inference-gpu-16"
  ["hpc-batch-compute-17"]="${GCP_PROJECT_TEST}:asia-southeast1-b:hpc-batch-compute-17"
)

for c in "${!CLUSTER_DIRS[@]}"; do
  IFS=":" read -r proj zone dir <<< "${CLUSTER_DIRS[$c]}"
  echo "=== Enforcing workload state on GKE $dir ($proj / $zone) ==="
  gcloud container clusters get-credentials "$dir" --zone "$zone" --project "$proj" || true
  
  case "$c" in
    prod-core-api-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/payment-processor.yaml" || true
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/network-daemon.yaml" || true
      ;;
    prod-user-auth-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/user-auth-service.yaml" || true
      ;;
    prod-data-pipeline-03)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/memory-cache-service.yaml" || true
      ;;
    prod-checkout-04)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/checkout-backend-api.yaml" || true
      ;;
    prod-storage-db-05)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/stateful-postgres-db.yaml" || true
      ;;
    edge-ingress-gateway-06)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/frontend-web-gateway.yaml" || true
      ;;
    prod-api-router-07)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/api-routing-proxy.yaml" || true
      ;;
    batch-analytics-08)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/batch-report-worker.yaml" || true
      ;;
    ai-training-dws-09)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/gemma-fine-tuning-job.yaml" || true
      ;;
    prod-auto-scaler-10)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/queue-worker-service.yaml" || true
      ;;
    prod-checkout-gateway-11)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/checkout-backend-service.yaml" || true
      ;;
    prod-order-processing-12)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/payment-api-gateway.yaml" || true
      ;;
    prod-catalog-sync-13)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/config-syncer-service.yaml" || true
      ;;
    prod-ha-payments-14)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/ha-payment-gateway-service.yaml" || true
      ;;
    prod-analytics-store-15)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/analytics-worker-service.yaml" || true
      ;;
    ai-inference-gpu-16)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/llm-batch-inference-job.yaml" || true
      ;;
    hpc-batch-compute-17)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/hpc-batch-analytics-job.yaml" || true
      ;;
  esac
done

echo "✔ Fleet workload reset complete."
