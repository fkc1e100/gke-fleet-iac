#!/usr/bin/env bash
set -eo pipefail

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
  echo "=== Deploying kube-agents event watcher to $c ($proj / $zone / $dir) ==="
  gcloud container clusters get-credentials "$c" --zone "$zone" --project "$proj"
  
  if [ -f "clusters/$dir/cluster-agent-event-watcher.yaml" ]; then
    kubectl apply -f "clusters/$dir/cluster-agent-event-watcher.yaml"
  fi
done

echo "=== Fleet Event Watcher Deployment Complete ==="
