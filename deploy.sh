#!/bin/bash
set -e

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."

# Create namespace if it doesn't exist
kubectl apply -f kubernetes/namespace.yaml

# Apply deployment and service
kubectl apply -f kubernetes/hello-deployment.yaml
kubectl apply -f kubernetes/hello-service.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl -n demo-python rollout status deployment/hello-world-deployment

# Get service details
echo "Service details:"
kubectl -n demo-python get service hello-world-service

echo "Deployment completed successfully!"
