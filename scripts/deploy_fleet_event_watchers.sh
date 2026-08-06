#!/usr/bin/env bash
set -eo pipefail

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
  ["complex-06"]="gca-gke-2025:us-central1-a"
)

for c in "${!CLUSTERS[@]}"; do
  IFS=":" read -r proj zone <<< "${CLUSTERS[$c]}"
  echo "=== Deploying kube-agents event watcher to $c ($proj / $zone) ==="
  gcloud container clusters get-credentials "$c" --zone "$zone" --project "$proj"
  
  if [ -f "clusters/$c/cluster-agent-event-watcher.yaml" ]; then
    kubectl apply -f "clusters/$c/cluster-agent-event-watcher.yaml"
  fi
done

echo "=== Fleet Event Watcher Deployment Complete ==="
