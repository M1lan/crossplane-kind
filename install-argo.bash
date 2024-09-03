#!/usr/bin/env bash
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
