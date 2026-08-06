# Cluster Scenario: complex-03

**Project**: `gca-gke-test`  
**Zone**: `us-central1-a`  
**Scenario**: ServiceAccount Token Projections Disabled + Missing Secret + RBAC Lockout Cascade

## Overview
This cluster demonstrates an authentication/authorization cascade:
1. `wl-complex-03-config-syncer` references a non-existent Secret `missing-api-signing-key` in `envFrom`, causing `CreateContainerConfigError`.
2. The Pod spec has `automountServiceAccountToken: false` set, preventing serviceaccount token mounting.
3. The ServiceAccount `restricted-sa` has no Role or RoleBinding assigned.

## Primary Symptoms
- Pod state: `CreateContainerConfigError` due to missing secret `missing-api-signing-key`.
- After creating the secret, pod crashes with API token missing & 403 Forbidden RBAC errors.

## Triage Instructions
1. Inspect deployment events: `kubectl describe deployment wl-complex-03-config-syncer -n prod-apps`
2. Create the missing secret `missing-api-signing-key`.
3. Set `automountServiceAccountToken: true` on the Deployment.
4. Bind a Role/ClusterRole to `restricted-sa` providing necessary RBAC permissions.
