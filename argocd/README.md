# ArgoCD Setup for Demo Python App

This directory contains the ArgoCD configuration for continuous deployment of the Demo Python App to Kubernetes.

## Prerequisites

1. ArgoCD installed in your Kubernetes cluster
2. Access to the ArgoCD UI or CLI

## Setup Instructions

### 1. Install ArgoCD (if not already installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then access the UI at: https://localhost:8080

### 3. Deploy the Application

```bash
# Apply the ArgoCD Application manifest
kubectl apply -f argocd/application.yaml
```

### 4. Verify Deployment

1. Check the ArgoCD UI to see the application status
2. Verify the application is deployed in the demo-python namespace:

```bash
kubectl get all -n demo-python
```

## How It Works

The ArgoCD Application is configured to:

1. Monitor the `kubernetes` directory in the GitHub repository
2. Automatically sync changes to the Kubernetes cluster
3. Create the namespace if it doesn't exist
4. Prune resources that are no longer defined in Git
5. Self-heal if manual changes are made to the cluster

## Continuous Deployment Flow

1. CI pipeline builds and pushes a new Docker image with version tag
2. CI updates the Kubernetes manifests with the new image version
3. ArgoCD detects the changes in the Git repository
4. ArgoCD automatically syncs the changes to the Kubernetes cluster

This GitOps approach ensures that the state of your application in the cluster always matches what's defined in Git.
