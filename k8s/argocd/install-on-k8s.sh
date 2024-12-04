#!/bin/bash

# Exit script on any error
set -e

echo "Starting ArgoCD installation on Kubernetes..."
## docs: https://argo-cd.readthedocs.io/en/stable/getting_started/

echo "1. Applying ArgoCD installation manifest..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "2. Waiting for ArgoCD pods to be ready..."
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

echo "3. Fetching ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: ${ARGOCD_PASSWORD}"

#echo "4. Exposing ArgoCD server using NodePort (optional - for local access)..."
#kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "NodePort"}}'

echo "ArgoCD server is ready. Access it using the Kubernetes Node IP and NodePort."
NODE_PORT=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "ArgoCD UI URL: http://${NODE_IP}:${NODE_PORT}"
echo "ArgoCD installation completed!"
