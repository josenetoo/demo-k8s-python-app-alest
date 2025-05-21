# Scripts for Demo K8s Python App

This directory contains utility scripts for managing the Demo K8s Python App.

## Version Manager

The `version-manager.sh` script provides a robust way to manage application versions across the entire project, following Windsurf principles for reproducible builds and consistent versioning.

### Features

- Automatic semantic versioning (MAJOR.MINOR.PATCH)
- Synchronization of version numbers across:
  - `version.txt` file
  - Kubernetes deployment manifests
  - Docker image tags
- Support for arm64 architecture tagging

### Usage

```bash
# Update to a specific version
./scripts/version-manager.sh 1.2.0

# Auto-increment patch version (e.g., 1.1.1 → 1.1.2)
./scripts/version-manager.sh
```

### How It Works

1. Validates semantic version format
2. Updates the version in `version.txt`
3. Updates the image tag in Kubernetes deployment manifest
4. Provides clear next steps for committing and pushing changes

### Integration with CI/CD

The version manager is designed to work seamlessly with our GitHub Actions CI/CD pipeline:

1. When you update the version locally and push changes, GitHub Actions will:
   - Build the Docker image with the new version tag
   - Push the image to Docker Hub
   - Ensure the Kubernetes manifests reference the correct image version
   - Commit any necessary updates back to the repository

2. ArgoCD will then detect the changes in the Kubernetes manifests and automatically deploy the new version.

This approach ensures that our deployment always uses the correct image version, maintaining the integrity of our GitOps workflow and following Windsurf principles for reproducible builds.
