#!/bin/bash
set -e

# Read current version
VERSION=$(cat version.txt)
DOCKER_REPO="josenetoalest/demo-python"

# Build with version tag and latest tag locally only
echo "Building Docker image $DOCKER_REPO:$VERSION locally"
docker build -t "$DOCKER_REPO:$VERSION" -t "$DOCKER_REPO:latest" .

echo "Successfully built $DOCKER_REPO:$VERSION and $DOCKER_REPO:latest locally"
echo ""
echo "NOTE: Images are built locally only and NOT pushed to Docker Hub."
echo "To deploy to production, commit and push changes to GitHub."
echo "The GitHub Actions CI pipeline will handle building and pushing the arm64 images."
echo "ArgoCD will then automatically deploy the new version to Kubernetes."
