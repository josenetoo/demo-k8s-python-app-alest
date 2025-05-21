#!/bin/bash
set -e

# Check if a version parameter is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <new-version>"
  echo "Example: $0 1.0.1"
  exit 1
fi

NEW_VERSION=$1

# Validate version format (simple check for MAJOR.MINOR.PATCH)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format MAJOR.MINOR.PATCH (e.g., 1.0.1)"
  exit 1
fi

# Get current version
CURRENT_VERSION=$(cat version.txt)

echo "Updating version from $CURRENT_VERSION to $NEW_VERSION"

# Update version.txt
echo $NEW_VERSION > version.txt

# Update Kubernetes deployment manifest with new version
sed -i '' "s|josenetoalest/demo-python:$CURRENT_VERSION|josenetoalest/demo-python:$NEW_VERSION|g" kubernetes/hello-deployment.yaml

echo "Version updated to $NEW_VERSION"
echo "Changes:"
echo "1. Updated version.txt"
echo "2. Updated Kubernetes deployment manifest"
echo ""
echo "Next steps:"
echo "1. Commit and push changes: git add . && git commit -m \"Bump version to $NEW_VERSION\" && git push"
echo "2. This will trigger the CI pipeline to build and push the new version"
echo "3. ArgoCD will automatically deploy the new version to Kubernetes"
