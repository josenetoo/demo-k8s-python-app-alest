#!/bin/bash
set -e

# Read current version
VERSION=$(cat version.txt)
DOCKER_REPO="josenetoalest/demo-python"

# Build with version tag and latest tag
echo "Building Docker image $DOCKER_REPO:$VERSION"
docker build -t "$DOCKER_REPO:$VERSION" -t "$DOCKER_REPO:latest" .

# Push images
echo "Pushing Docker image $DOCKER_REPO:$VERSION"
docker push "$DOCKER_REPO:$VERSION"
docker push "$DOCKER_REPO:latest"

echo "Successfully built and pushed $DOCKER_REPO:$VERSION and $DOCKER_REPO:latest"
