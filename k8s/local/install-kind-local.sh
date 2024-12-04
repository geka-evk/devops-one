#!/bin/bash

# Exit script on any error
set -e

echo "==> Installing local kind k8s cluster..."
kind create cluster --config ../kind/kind-cluster.yaml
KIND_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "... kind k8s IP: ${KIND_IP}"

echo "==> Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=120s
kubectl get pods --namespace cert-manager
kubectl apply -f ../cert-manager/klm-ca-secret.yaml
kubectl apply -f ../cert-manager/klm-ca-issuer.yaml
kubectl get clusterissuer

echo "==> Installing nginx ingress using helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install klm-local-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalIPs[0]="$KIND_IP" \
  --set controller.extraArgs.enable-ssl-passthrough=true
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "==> Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

kubectl apply -f ../argocd/argocd-server-cert.yaml
kubectl wait --for=condition=ready certificate argocd-server-cert -n argocd --timeout=120s
kubectl apply -f ../argocd/argocd-server-ingress.yaml

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "...ArgoCD admin password: ${ARGOCD_PASSWORD}"
