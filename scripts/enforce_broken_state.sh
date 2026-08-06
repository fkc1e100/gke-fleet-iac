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
  ["cluster-01"]="${GCP_PROJECT_2025}:us-central1-a:prod-core-api-01"
  ["cluster-02"]="${GCP_PROJECT_2025}:us-central1-a:prod-user-auth-02"
  ["cluster-03"]="${GCP_PROJECT_2025}:us-east1-b:prod-data-pipeline-03"
  ["cluster-04"]="${GCP_PROJECT_2025}:us-east4-a:prod-checkout-04"
  ["cluster-05"]="${GCP_PROJECT_2025}:us-west1-a:prod-storage-db-05"
  ["cluster-06"]="${GCP_PROJECT_TEST}:us-central1-a:edge-ingress-gateway-06"
  ["cluster-07"]="${GCP_PROJECT_TEST}:us-east1-c:prod-api-router-07"
  ["cluster-08"]="${GCP_PROJECT_2025}:us-west2-a:batch-analytics-08"
  ["cluster-09"]="${GCP_PROJECT_2025}:europe-west1-b:ai-training-dws-09"
  ["cluster-10"]="${GCP_PROJECT_TEST}:us-west1-b:prod-auto-scaler-10"
  ["complex-01"]="${GCP_PROJECT_2025}:europe-west3-a:prod-checkout-gateway-11"
  ["complex-02"]="${GCP_PROJECT_2025}:asia-east1-a:prod-order-processing-12"
  ["complex-03"]="${GCP_PROJECT_TEST}:europe-west1-c:prod-catalog-sync-13"
  ["complex-04"]="${GCP_PROJECT_TEST}:europe-west3-b:prod-ha-payments-14"
  ["complex-05"]="${GCP_PROJECT_TEST}:asia-east1-b:prod-analytics-store-15"
  ["complex-06"]="${GCP_PROJECT_2025}:asia-southeast1-a:ai-inference-gpu-16"
  ["complex-07"]="${GCP_PROJECT_TEST}:asia-southeast1-b:hpc-batch-compute-17"
)

for c in "${!CLUSTER_DIRS[@]}"; do
  IFS=":" read -r proj zone dir <<< "${CLUSTER_DIRS[$c]}"
  echo "=== Enforcing workload state on GKE $dir ($proj / $zone) ==="
  gcloud container clusters get-credentials "$dir" --zone "$zone" --project "$proj" || true
  
  case "$c" in
    cluster-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/payment-processor.yaml" || true
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/network-daemon.yaml" || true
      ;;
    cluster-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/user-auth-service.yaml" || true
      ;;
    cluster-03)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/memory-cache-service.yaml" || true
      ;;
    cluster-04)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/checkout-backend-api.yaml" || true
      ;;
    cluster-05)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/stateful-postgres-db.yaml" || true
      ;;
    cluster-06)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/frontend-web-gateway.yaml" || true
      ;;
    cluster-07)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/api-routing-proxy.yaml" || true
      ;;
    cluster-08)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/batch-report-worker.yaml" || true
      ;;
    cluster-09)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/gemma-fine-tuning-job.yaml" || true
      ;;
    cluster-10)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/queue-worker-service.yaml" || true
      ;;
    complex-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/checkout-backend-service.yaml" || true
      ;;
    complex-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/payment-api-gateway.yaml" || true
      ;;
    complex-03)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/config-syncer-service.yaml" || true
      ;;
    complex-04)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/ha-payment-gateway-service.yaml" || true
      ;;
    complex-05)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/analytics-worker-service.yaml" || true
      ;;
    complex-06)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/llm-batch-inference-job.yaml" || true
      ;;
    complex-07)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/hpc-batch-analytics-job.yaml" || true
      ;;
  esac
done

echo "✔ Fleet workload reset complete."
