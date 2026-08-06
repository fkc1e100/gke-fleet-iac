#!/usr/bin/env bash
set -eo pipefail

echo "============================================================"
echo " Starting Daily 0200h Fleet Reset to Canonical Failing State"
echo "============================================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

declare -A CLUSTERS=(
  ["cluster-01"]="gca-gke-2025:us-central1-a"
  ["cluster-02"]="gca-gke-2025:us-central1-a"
  ["cluster-03"]="gca-gke-2025:us-central1-a"
  ["cluster-04"]="gca-gke-2025:us-central1-a"
  ["cluster-05"]="gca-gke-2025:us-central1-a"
  ["cluster-06"]="gca-gke-test:us-central1-a"
  ["cluster-07"]="gca-gke-test:us-central1-a"
  ["cluster-08"]="gca-gke-2025:us-central1-a"
  ["cluster-09"]="gca-gke-2025:us-central1-a"
  ["cluster-10"]="gca-gke-test:us-central1-a"
  ["complex-01"]="gca-gke-2025:us-central1-a"
  ["complex-02"]="gca-gke-2025:us-central1-a"
  ["complex-03"]="gca-gke-test:us-central1-a"
  ["complex-04"]="gca-gke-test:us-central1-a"
  ["complex-05"]="gca-gke-test:us-central1-a"
)

for c in "${!CLUSTERS[@]}"; do
  IFS=":" read -r proj zone <<< "${CLUSTERS[$c]}"
  echo "=== Enforcing failing state on $c ($proj / $zone) ==="
  gcloud container clusters get-credentials "$c" --zone "$zone" --project "$proj"
  
  if [ -f "${REPO_ROOT}/clusters/${proj}/${c}/cluster-agent-event-watcher.yaml" ]; then
    kubectl apply -f "${REPO_ROOT}/clusters/${proj}/${c}/cluster-agent-event-watcher.yaml" || true
  fi
  
  case "$c" in
    cluster-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-01-crashloop.yaml" || true
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-01-ip-exhaustion.yaml" || true
      ;;
    cluster-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-02-private-image-auth-fail.yaml" || true
      ;;
    cluster-08)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-08-spot-obtainability-failure.yaml" || true
      ;;
    cluster-09)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-09-flex-obtainability-timeout.yaml" || true
      ;;
    complex-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-01-webhook-deadlock.yaml" || true
      ;;
    complex-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-02-dns-netpol-failure.yaml" || true
      ;;
    complex-03)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-03-rbac-token-lockout.yaml" || true
      ;;
    complex-04)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-04-cni-affinity-exhaustion.yaml" || true
      ;;
    complex-05)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-05-storage-init-deadlock.yaml" || true
      ;;
  esac
done

echo "============================================================"
echo " Fleet reset completed successfully."
echo "============================================================"
