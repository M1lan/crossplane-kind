#!/usr/bin/env bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xsel -ib
sleep 3
nohup xdg-open http://localhost:30183 >/dev/null 2>&1 &
