#!/bin/bash
set -e

# This script manages version updates across the application
# It ensures that version numbers are consistent across:
# 1. version.txt
# 2. Kubernetes deployment manifests
# 3. Docker image tags

# Function to validate semantic version format
validate_version() {
  local version=$1
  if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format MAJOR.MINOR.PATCH (e.g., 1.1.1)"
    exit 1
  fi
}

# Function to update version in version.txt
update_version_file() {
  local new_version=$1
  echo "$new_version" > version.txt
  echo "Updated version.txt to $new_version"
}

# Function to update Kubernetes deployment manifest
update_k8s_manifest() {
  local current_version=$1
  local new_version=$2
  
  # Update the image tag in the deployment manifest
  # This handles both the case where we're updating from a non-arm64 tag
  # and the case where we're updating from an arm64 tag
  if grep -q "josenetoalest/demo-python:.*-arm64" kubernetes/hello-deployment.yaml; then
    sed -i '' "s|josenetoalest/demo-python:.*-arm64|josenetoalest/demo-python:${new_version}-arm64|g" kubernetes/hello-deployment.yaml
  else
    sed -i '' "s|josenetoalest/demo-python:.*|josenetoalest/demo-python:${new_version}-arm64|g" kubernetes/hello-deployment.yaml
  fi
  
  echo "Updated Kubernetes deployment manifest to use image version $new_version-arm64"
}

# Function to display next steps
show_next_steps() {
  local new_version=$1
  echo ""
  echo "Next steps:"
  echo "1. Commit and push changes: git add . && git commit -m \"Bump version to $new_version\" && git push"
  echo "2. This will trigger the CI pipeline to build and push the new version"
  echo "3. ArgoCD will automatically deploy the new version to Kubernetes"
}

# Main execution starts here
if [ $# -ne 1 ]; then
  # If no version is provided, increment the patch version
  CURRENT_VERSION=$(cat version.txt)
  
  # Split the version into components
  MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
  MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
  PATCH=$(echo $CURRENT_VERSION | cut -d. -f3)
  
  # Increment patch version
  PATCH=$((PATCH + 1))
  
  # Construct new version
  NEW_VERSION="$MAJOR.$MINOR.$PATCH"
  
  echo "Auto-incrementing patch version from $CURRENT_VERSION to $NEW_VERSION"
else
  # If version is provided, use it
  NEW_VERSION=$1
  validate_version "$NEW_VERSION"
  CURRENT_VERSION=$(cat version.txt)
  echo "Updating version from $CURRENT_VERSION to $NEW_VERSION"
fi

# Update version in all required places
update_version_file "$NEW_VERSION"
update_k8s_manifest "$CURRENT_VERSION" "$NEW_VERSION"

echo ""
echo "Version updated to $NEW_VERSION"
echo "Changes:"
echo "1. Updated version.txt"
echo "2. Updated Kubernetes deployment manifest"

show_next_steps "$NEW_VERSION"
