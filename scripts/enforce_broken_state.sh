#!/usr/bin/env bash
set -eo pipefail

echo "============================================================"
echo " Starting Daily 0200h Fleet Reset to Canonical Failing State"
echo "============================================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

declare -A CLUSTER_DIRS=(
  ["cluster-01"]="gca-gke-2025:us-central1-a:cluster-01-ip-exhaustion-crashloop"
  ["cluster-02"]="gca-gke-2025:us-central1-a:cluster-02-private-registry-auth-fail"
  ["cluster-03"]="gca-gke-2025:us-central1-a:cluster-03-oomkilled-memory-limit"
  ["cluster-04"]="gca-gke-2025:us-central1-a:cluster-04-missing-secret-key-crash"
  ["cluster-05"]="gca-gke-2025:us-central1-a:cluster-05-pvc-unbound-storageclass"
  ["cluster-06"]="gca-gke-test:us-central1-a:cluster-06-ingress-tls-cert-missing"
  ["cluster-07"]="gca-gke-test:us-central1-a:cluster-07-liveness-probe-failure"
  ["cluster-08"]="gca-gke-2025:us-central1-a:cluster-08-spot-obtainability-lockout"
  ["cluster-09"]="gca-gke-2025:us-central1-a:cluster-09-flex-dws-obtainability-timeout"
  ["cluster-10"]="gca-gke-test:us-central1-a:cluster-10-hpa-cpu-metric-missing"
  ["complex-01"]="gca-gke-2025:us-central1-a:complex-01-webhook-deadlock-wi-auth"
  ["complex-02"]="gca-gke-2025:us-central1-a:complex-02-dns-netpol-gcs-block"
  ["complex-03"]="gca-gke-test:us-central1-a:complex-03-gar-auth-sa-token-lockout"
  ["complex-04"]="gca-gke-test:us-central1-a:complex-04-pod-affinity-cni-ip-starvation"
  ["complex-05"]="gca-gke-test:us-central1-a:complex-05-pd-rwo-multiattach-sysctl"
  ["complex-06"]="gca-gke-2025:us-central1-a:complex-06-spot-gpu-stockout-fallback"
  ["complex-07"]="gca-gke-test:us-central1-a:complex-07-cpu-stockout-compute-class"
)

for c in "${!CLUSTER_DIRS[@]}"; do
  IFS=":" read -r proj zone dir <<< "${CLUSTER_DIRS[$c]}"
  echo "=== Enforcing failing state on $c ($proj / $zone / $dir) ==="
  gcloud container clusters get-credentials "$c" --zone "$zone" --project "$proj"
  
  if [ -f "${REPO_ROOT}/clusters/${dir}/cluster-agent-event-watcher.yaml" ]; then
    kubectl apply -f "${REPO_ROOT}/clusters/${dir}/cluster-agent-event-watcher.yaml" || true
  fi
  
  case "$c" in
    cluster-01)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-01-crashloop.yaml" || true
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-01-ip-exhaustion.yaml" || true
      ;;
    cluster-02)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-02-private-image-auth-fail.yaml" || true
      ;;
    cluster-03)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-03-oomkilled.yaml" || true
      ;;
    cluster-04)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-04-missing-secret-key.yaml" || true
      ;;
    cluster-05)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-05-pvc-unbound.yaml" || true
      ;;
    cluster-06)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-06-ingress-tls-missing.yaml" || true
      ;;
    cluster-07)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-07-liveness-probe-fail.yaml" || true
      ;;
    cluster-08)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-08-spot-obtainability-failure.yaml" || true
      ;;
    cluster-09)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-09-flex-obtainability-timeout.yaml" || true
      ;;
    cluster-10)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/wl-10-hpa-metric-missing.yaml" || true
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
    complex-06)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-06-gpu-stockout-autoscaling.yaml" || true
      ;;
    complex-07)
      kubectl apply -f "${REPO_ROOT}/manifests/workloads/complex-07-cpu-stockout-compute-class.yaml" || true
      ;;
  esac
done

echo "============================================================"
echo " Fleet reset completed successfully."
echo "============================================================"
