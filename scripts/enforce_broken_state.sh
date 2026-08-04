#!/usr/bin/env bash
set -eo pipefail

echo "============================================================"
echo " Starting Daily 0200h Fleet Reset to Canonical Failing State"
echo "============================================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Step 1: Enforcing common manifests (kube-agents event watcher)..."
find "${REPO_ROOT}/clusters" -name "cluster-agent-event-watcher.yaml" -exec kubectl apply -f {} \; || true

echo "Step 2: Re-applying canonical failing workloads..."
kubectl apply -f "${REPO_ROOT}/manifests/workloads/" --recursive --force || true

echo "============================================================"
echo " Fleet reset completed successfully."
echo "============================================================"
