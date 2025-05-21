# Manual Kubernetes Deployment Guide

This guide provides step-by-step instructions for manually deploying the Demo Python App to a Kubernetes cluster, following Windsurf principles.

## Prerequisites

- Kubernetes cluster with kubectl configured
- Docker Hub access (to pull the container image)
- Basic understanding of Kubernetes concepts

## Deployment Steps

### 1. Using the Deployment Script (Recommended)

The simplest way to deploy the application is using the provided deployment script:

```bash
# Make the script executable if needed
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

This script will:
1. Create the `demo-python` namespace if it doesn't exist
2. Apply the Kubernetes manifests (deployment and service)
3. Wait for the deployment to be ready
4. Display the service details

### 2. Manual Deployment

If you prefer to deploy manually, follow these steps:

#### Create the Namespace

```bash
kubectl apply -f kubernetes/namespace.yaml
```

#### Deploy the Application

```bash
kubectl apply -f kubernetes/hello-deployment.yaml
kubectl apply -f kubernetes/hello-service.yaml
```

#### Verify the Deployment

```bash
# Check the deployment status
kubectl -n demo-python get deployments

# Check the pods
kubectl -n demo-python get pods

# Check the service
kubectl -n demo-python get services
```

## Accessing the Application

### LoadBalancer Service Type

If your Kubernetes cluster supports LoadBalancer services (e.g., cloud providers like AWS, GCP, Azure):

```bash
# Get the external IP
kubectl -n demo-python get service hello-world-service

# Access the application
# http://<EXTERNAL-IP>:8080
```

### NodePort Service Type

If you're using a local cluster or one that doesn't support LoadBalancer:

1. Change the service type to NodePort in `kubernetes/hello-service.yaml`:
   ```yaml
   spec:
     type: NodePort
     ...
   ```

2. Apply the updated service:
   ```bash
   kubectl apply -f kubernetes/hello-service.yaml
   ```

3. Get the NodePort:
   ```bash
   kubectl -n demo-python get service hello-world-service
   ```

4. Access the application:
   ```
   http://<NODE-IP>:<NODE-PORT>
   ```

## Scaling the Application

To scale the application to more replicas:

```bash
kubectl -n demo-python scale deployment hello-world-deployment --replicas=3
```

## Updating the Application

To update the application to a new version:

1. Update the image version in `kubernetes/hello-deployment.yaml`
2. Apply the updated deployment:
   ```bash
   kubectl apply -f kubernetes/hello-deployment.yaml
   ```

Alternatively, use the kubectl set image command:
```bash
kubectl -n demo-python set image deployment/hello-world-deployment hello-world-container=josenetoalest/demo-python:1.0.1
```

## Monitoring the Deployment

```bash
# Watch the deployment status
kubectl -n demo-python rollout status deployment/hello-world-deployment

# View deployment details
kubectl -n demo-python describe deployment hello-world-deployment

# View pod logs
kubectl -n demo-python logs -l app=hello-world
```

## Troubleshooting

### Pods Not Starting

If pods are not starting or are in a crash loop:

```bash
# Get pod details
kubectl -n demo-python describe pod <pod-name>

# Check pod logs
kubectl -n demo-python logs <pod-name>
```

### Service Not Accessible

If the service is not accessible:

```bash
# Check service details
kubectl -n demo-python describe service hello-world-service

# Check endpoints
kubectl -n demo-python get endpoints hello-world-service
```

### Resource Constraints

If pods are pending due to resource constraints:

```bash
# Check node resources
kubectl describe nodes

# Adjust resource requests/limits in deployment.yaml if needed
```

## Cleanup

To remove the application from your cluster:

```bash
kubectl delete -f kubernetes/hello-service.yaml
kubectl delete -f kubernetes/hello-deployment.yaml
kubectl delete -f kubernetes/namespace.yaml
```

Or simply:
```bash
kubectl delete namespace demo-python
```

## Windsurf Principles Applied

This deployment follows Windsurf principles for Kubernetes applications:

1. **Use Official & Minimal Base Images**: The deployment uses the minimal `python:3.9-slim` base image.
2. **Reproducible Builds**: Using specific image version tags ensures reproducibility.
3. **Security Best Practices**: 
   - Running as non-root user
   - Setting security context with dropped capabilities
   - Implementing resource limits to prevent resource exhaustion
4. **Health Monitoring**: Using liveness and readiness probes for better reliability.
5. **Resource Efficiency**: Setting appropriate resource requests and limits.
