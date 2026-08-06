# GKE Fleet Infrastructure as Code (IaC) & GitOps Repository

This repository is the dedicated, isolated GitOps single source of truth for GKE fleet configurations across GCP projects `gca-gke-2025` and `gca-gke-test`.

---

## Complex Triage Scenarios (`complex-01` .. `complex-05`)

| Cluster | Project | Failure Scenario | Key Symptoms / Components |
|---|---|---|---|
| `complex-01` | `gca-gke-2025` | **Mutating Webhook Deadlock** | Cluster-wide `MutatingWebhookConfiguration` fails with timeout on dead backend service, blocking all pod creations |
| `complex-02` | `gca-gke-2025` | **NetworkPolicy DNS Isolation & Host Mismatch** | NetworkPolicy blocks UDP/TCP egress to DNS (port 53); backend crashes trying to resolve invalid StatefulSet service host |
| `complex-03` | `gca-gke-test` | **RBAC & SA Token Lockout Cascade** | Missing secret causes `CreateContainerConfigError`; `automountServiceAccountToken: false` & zero RBAC permissions on ServiceAccount |
| `complex-04` | `gca-gke-test` | **Scheduling Deadlock & CNI IP Starvation** | Strict `podAntiAffinity` on 2-node cluster + 4 vCPU requests + 35 pods exhausting CNI Pod IP allocation |
| `complex-05` | `gca-gke-test` | **Storage Multi-Attach & InitContainer Privilege Fail** | ReadWriteOnce PVC attached to multiple pods (`Multi-Attach error`) + unprivileged `sysctl` initContainer failure |

---

## Fleet Layout

```text
clusters/
├── gca-gke-2025/
│   ├── cluster-01 .. cluster-05
│   ├── cluster-08, cluster-09
│   ├── complex-01/
│   └── complex-02/
└── gca-gke-test/
    ├── cluster-06, cluster-07, cluster-10
    ├── complex-03/
    ├── complex-04/
    └── complex-05/
```

---

## Fleet Management Scripts

- `scripts/enforce_broken_state.sh`: Deploys event watchers and applies all failure scenario workloads across the fleet.
- `scripts/deploy_fleet_event_watchers.sh`: Deploys `kube-agents` event watchers to all fleet clusters.
