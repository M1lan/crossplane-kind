#!/usr/bin/env bash

if kubectl get namespace crossplane-system > /dev/null 2>&1; then
  echo "Namespace crossplane-system already exists!"
else
  echo "Creating namespace crossplane-system..."
  kubectl create namespace crossplane-system
fi

echo "Installing crossplane version"
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm upgrade --install crossplane --namespace crossplane-system crossplane-stable/crossplane --devel
kubectl wait --for condition=Available=True --timeout=300s deployment/crossplane --namespace crossplane-system
