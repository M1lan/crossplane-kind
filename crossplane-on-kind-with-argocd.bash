#!/usr/bin/env bash
set -euo pipefail

#### kind
kind --version || exit 1

echo "Creating kind cluster"
kind create cluster --config - --wait 3m <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: crossplane
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30183
    hostPort: 30183
    listenAddress: "127.0.0.1"
    protocol: TCP
EOF

echo "Kubeconfig:"
kind get kubeconfig --name crossplane

echo "Switching kubectl context to kind-crossplane"
kubectl config use-context kind-crossplane
echo "current context is: $(kubectl config current-context)"

###

### crossplane
if kubectl get namespace crossplane-system &> /dev/null; then
  echo "Namespace crossplane-system already exists!"
else
  echo "Creating namespace crossplane-system..."
  kubectl create namespace crossplane-system
fi

echo "Installing stable crossplane with helm"
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm upgrade --install crossplane --namespace crossplane-system crossplane-stable/crossplane --devel
kubectl wait --for condition=Available=True --timeout=300s deployment/crossplane --namespace crossplane-system

###

### argocd
echo "Installing ArgoCD..."

if kubectl get namespace argocd > /dev/null 2>&1; then
    echo "Namespace argocd already exists"
else
    echo "Creating namespace argocd"
    kubectl create namespace argocd
fi

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
kubectl wait --for condition=Available=True --timeout=300s deployment/argocd-server --namespace argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc argocd-server -n argocd --type merge --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 30183 }]'

## apps
kubectl apply -f bootstrap.yaml
