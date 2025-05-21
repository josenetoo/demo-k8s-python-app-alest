#!/bin/bash
set -e

echo "Setting up ArgoCD for continuous deployment..."

# Check if ArgoCD namespace exists, create if not
if ! kubectl get namespace argocd &>/dev/null; then
  echo "Creating ArgoCD namespace..."
  kubectl create namespace argocd
fi

# Check if ArgoCD is installed, install if not
if ! kubectl get deployments -n argocd argocd-server &>/dev/null; then
  echo "Installing ArgoCD..."
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  
  echo "Waiting for ArgoCD server to be ready..."
  kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
else
  echo "ArgoCD is already installed."
fi

# Deploy the application
echo "Deploying the application to ArgoCD..."
kubectl apply -f argocd/application.yaml

echo "ArgoCD setup completed!"
echo "To access ArgoCD UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then access the UI at: https://localhost:8080"
echo "Default username: admin"
echo "To get the password, run: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
