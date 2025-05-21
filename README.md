# Demo K8s Python App

A simple "Hello World" Python Flask application deployed to Kubernetes following Windsurf principles, with complete CI/CD pipeline using GitHub Actions and ArgoCD.

## Project Structure

```
demo-k8s-python-app/
├── .github/
│   └── workflows/         # GitHub Actions workflows
├── app/
│   ├── app.py             # Flask application
│   └── requirements.txt   # Python dependencies
├── argocd/
│   ├── application.yaml   # ArgoCD Application manifest
│   ├── setup-argocd.sh    # ArgoCD setup script
│   └── README.md          # ArgoCD documentation
├── kubernetes/
│   ├── namespace.yaml     # Kubernetes Namespace
│   ├── hello-deployment.yaml  # Kubernetes Deployment
│   └── hello-service.yaml     # Kubernetes Service
├── Dockerfile             # Container definition
├── .dockerignore          # Files to exclude from Docker build
├── build.sh               # Script to build and push Docker image with version
├── deploy.sh              # Script for manual Kubernetes deployment
├── version.txt            # Current application version
├── PLANNING.MD            # Project planning document
├── TASKS.MD               # Implementation tasks
├── IMPLEMENTATION.md      # Implementation summary
└── README.md              # This file
```

## Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH). The current version is stored in `version.txt`.

To build and push a versioned Docker image:

```bash
# Run the build script
./build.sh
```

This will build and push the image with both the version tag and `latest` tag.

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

### Manual Deployment

```bash
# Run the deployment script
./deploy.sh
```

This will:
1. Create the `demo-python` namespace if it doesn't exist
2. Apply the Kubernetes manifests
3. Wait for the deployment to be ready
4. Display the service details

### Continuous Deployment with ArgoCD

For automated continuous deployment, we use ArgoCD following GitOps principles.

```bash
# Set up ArgoCD
./argocd/setup-argocd.sh
```

See the [ArgoCD README](./argocd/README.md) for more details.

## CI/CD Pipeline

### Continuous Integration (CI)

GitHub Actions is used for CI. On every push to the `main` branch, the workflow:
1. Builds the Docker image
2. Tags it with the version from `version.txt` and `latest`
3. Pushes the image to Docker Hub
4. Updates the Kubernetes manifests with the new version
5. Commits and pushes the changes back to the repository

### Continuous Deployment (CD)

ArgoCD is used for CD. It:
1. Monitors the `kubernetes` directory in the GitHub repository
2. Automatically syncs changes to the Kubernetes cluster
3. Ensures the cluster state matches what's defined in Git

## Windsurf Principles Applied

This project follows Windsurf principles for Dockerized applications:

1. **Use Official & Minimal Base Images**: Using `python:3.9-slim` as the base image.
2. **Reproducible Builds**: Pinned dependency versions in requirements.txt and explicit image versioning.
3. **Optimize Layers & Build Cache**: Ordered Dockerfile commands from least to most frequently changing, using .dockerignore.
4. **Stateless & Configurable Containers**: Using environment variables for configuration.
5. **Security Best Practices**: Running as non-root user, dropping capabilities, implementing resource limits, and using security contexts in Kubernetes.
