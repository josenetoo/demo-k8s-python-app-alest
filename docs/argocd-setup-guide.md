# ArgoCD Setup Guide for Kubernetes

This guide provides detailed instructions for setting up ArgoCD in your Kubernetes cluster and configuring it for continuous deployment of the Demo Python App.

## Prerequisites

- A Kubernetes cluster with kubectl configured
- Cluster admin access
- Helm (optional, for Helm-based installation)

## Installation Options

### Option 1: Using the Setup Script (Recommended)

The simplest way to set up ArgoCD is to use the provided setup script:

```bash
# Make the script executable if needed
chmod +x argocd/setup-argocd.sh

# Run the setup script
./argocd/setup-argocd.sh
```

This script will:
1. Create the ArgoCD namespace if it doesn't exist
2. Install ArgoCD if it's not already installed
3. Deploy the application to ArgoCD
4. Provide instructions for accessing the ArgoCD UI

### Option 2: Manual Installation

If you prefer to install ArgoCD manually, follow these steps:

#### 1. Create ArgoCD Namespace

```bash
kubectl create namespace argocd
```

#### 2. Install ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

#### 3. Access the ArgoCD API Server

By default, the ArgoCD API server is not exposed externally. You have several options to access it:

**Port Forwarding:**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Then access the UI at: https://localhost:8080

**Expose with LoadBalancer:**
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

**Ingress:**
Create an Ingress resource for the argocd-server service (requires an Ingress controller).

#### 4. Login to ArgoCD

Get the initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Login with username: `admin` and the password from the previous command.

#### 5. Deploy the Application

Apply the ArgoCD Application manifest:
```bash
kubectl apply -f argocd/application.yaml
```

## Accessing the ArgoCD UI

After installation, you can access the ArgoCD UI to monitor your applications:

1. If using port forwarding: https://localhost:8080
2. If using LoadBalancer: https://<EXTERNAL-IP>
3. If using Ingress: Use your configured hostname

## Configuring the Application

The ArgoCD Application is defined in `argocd/application.yaml`. This manifest tells ArgoCD:

1. Which Git repository to monitor (`spec.source.repoURL`)
2. Which path within the repository contains the Kubernetes manifests (`spec.source.path`)
3. Which namespace to deploy to (`spec.destination.namespace`)
4. The sync policy (automated or manual)

You can customize this manifest to suit your specific requirements.

## Sync Policies

The application is configured with automated sync:

```yaml
syncPolicy:
  automated:
    prune: true    # Deletes resources that are no longer defined in Git
    selfHeal: true # Reverts manual changes made to the cluster
```

If you prefer manual syncing, you can remove the `automated` section or set it to `false`.

## Troubleshooting

### Application Not Syncing

If your application is not syncing correctly:

1. Check the Application status in the ArgoCD UI
2. Verify that the Git repository is accessible
3. Ensure the Kubernetes manifests in the specified path are valid
4. Check the ArgoCD logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
   ```

### Authentication Issues

If you're having trouble logging in:

1. Reset the admin password:
   ```bash
   kubectl -n argocd patch secret argocd-secret \
     -p '{"stringData": {"admin.password": "$2a$10$mivhwttXM0U5eBrZGtQsv.P8ZUEgYgIDj2zYIRXQZP7yHqQxw7Vem", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
   ```
   This resets the password to "admin"

2. Restart the ArgoCD server:
   ```bash
   kubectl -n argocd rollout restart deployment argocd-server
   ```

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [ArgoCD CLI Installation](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
