# GKE Fleet Infrastructure as Code (IaC) & GitOps Repository

This repository is the dedicated, isolated GitOps single source of truth for GKE fleet configurations across GCP projects `gca-gke-2025` and `gca-gke-test`.

---

## Directory Layout

```text
clusters/
├── gca-gke-2025/
│   └── kcc-dash-dont-delete/
│       ├── compute-classes/
│       ├── security-policies/
│       └── hpa/
└── gca-gke-test/
    ├── gke-a2-highgpu/
    ├── gke-a2-ultra/
    ├── gke-a3-mega/
    └── gke-tpuv6-dws/
```

---

## GitOps Engine

Reconciled automatically by **Argo CD** deployed on `kcc-dash-dont-delete` in namespace `argocd`.
