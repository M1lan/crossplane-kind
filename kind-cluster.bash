#!/usr/bin/env bash
set -euo pipefail
echo "Creating kind cluster"
kind create cluster --config ./kind-cluster.yaml --wait 3m
kind get kubeconfig --name crossplane
kubectl config use-context kind-crossplane
