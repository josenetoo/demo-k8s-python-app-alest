# Setting up GitHub Secrets for CI Pipeline

To enable the CI pipeline to push Docker images to Docker Hub, you need to set up the following secrets in your GitHub repository:

## Required Secrets

1. `DOCKERHUB_USERNAME`: Your Docker Hub username
2. `DOCKERHUB_TOKEN`: A Docker Hub access token (not your password)

## Steps to Create a Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Click on your username in the top-right corner and select "Account Settings"
3. Go to the "Security" tab
4. Click "New Access Token"
5. Give your token a description (e.g., "GitHub Actions")
6. Select the appropriate permissions (at minimum, "Read & Write" for repositories)
7. Click "Generate"
8. Copy the token immediately (you won't be able to see it again)

## Steps to Add Secrets to Your GitHub Repository

1. Go to your GitHub repository at https://github.com/josenetoo/demo-k8s-python-app-alest
2. Click on "Settings" tab
3. In the left sidebar, click on "Secrets and variables" > "Actions"
4. Click "New repository secret"
5. Add the following secrets:
   - Name: `DOCKERHUB_USERNAME`
   - Value: Your Docker Hub username (e.g., `josenetoalest`)
   - Click "Add secret"
   - Name: `DOCKERHUB_TOKEN`
   - Value: The access token you created in Docker Hub
   - Click "Add secret"

## Verifying the Setup

After adding the secrets, the CI pipeline will be able to authenticate with Docker Hub and push images. You can verify this by:

1. Making a small change to the application code
2. Committing and pushing the change to GitHub
3. Going to the "Actions" tab in your GitHub repository
4. Checking that the workflow runs successfully and pushes the image to Docker Hub

## Troubleshooting

If the CI pipeline fails with authentication errors:

1. Check that the secrets are correctly named (`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`)
2. Verify that the Docker Hub access token has the appropriate permissions
3. Ensure the token is still valid (they can expire)
4. Check the GitHub Actions logs for specific error messages
