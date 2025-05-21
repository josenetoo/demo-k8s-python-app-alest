# Demo K8s Python App

A simple "Hello World" Python Flask application deployed to Kubernetes following Windsurf principles.

## Project Structure

```
demo-k8s-python-app/
├── app/
│   ├── app.py             # Flask application
│   └── requirements.txt   # Python dependencies
├── kubernetes/
│   ├── hello-deployment.yaml  # Kubernetes Deployment
│   └── hello-service.yaml     # Kubernetes Service
├── Dockerfile             # Container definition
├── .dockerignore          # Files to exclude from Docker build
├── PLANNING.MD            # Project planning document
├── TASKS.MD               # Implementation tasks
└── README.md              # This file
```

## Building and Running Locally

```bash
# Build the Docker image
docker build -t josenetoalest/demo-python:latest .

# Run the container locally
docker run -p 8080:8080 josenetoalest/demo-python:latest

# Access the application
# http://localhost:8080
```

## Deploying to Kubernetes

```bash
# Push the image to Docker Hub
docker push josenetoalest/demo-python:latest

# Apply Kubernetes manifests
kubectl apply -f kubernetes/hello-deployment.yaml
kubectl apply -f kubernetes/hello-service.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services
```

## Windsurf Principles Applied

This project follows Windsurf principles for Dockerized applications:

1. **Use Official & Minimal Base Images**: Using `python:3.9-slim` as the base image.
2. **Reproducible Builds**: Pinned dependency versions in requirements.txt.
3. **Optimize Layers & Build Cache**: Ordered Dockerfile commands from least to most frequently changing.
4. **Stateless & Configurable Containers**: Using environment variables for configuration.
5. **Security Best Practices**: Running as non-root user, dropping capabilities, and implementing resource limits.
