# Autonomous SRE Benchmark Evaluation Suite

This directory contains the ground-truth evaluation key (`ground_truth.json`) used by the evaluation harness to score LLM agent triage performance.

## ⚠️ Benchmark Isolation Rules
- **Do not expose `ground_truth.json` to the LLM agent during triage evaluation.**
- The LLM agent under test should interact only with Kubernetes APIs (`kubectl`), GCP APIs (`gcloud`), and workspace application code.
- `ground_truth.json` is ignored by `.gitignore` to prevent leakage into public agent context windows.
