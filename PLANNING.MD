# PLANNING: Hello-World Application Deployment to Kubernetes

## 1. High-Level Direction 🎯

The primary objective is to deploy a simple "hello-world" web application. This involves containerizing the application using Docker, pushing the container image to a registry, and then deploying and managing it on a Kubernetes cluster. The application must be accessible externally via port 8080. This project aims to establish a clear, repeatable, and well-documented process for basic application deployment on Kubernetes.

## 2. Scope  범위

**In Scope:**

* **Application:** A basic "hello-world" application (e.g., using a pre-built image like `nginxdemos/hello` or a simple custom app in Python/Node.js).
* **Containerization:**
    * Creating a `Dockerfile` if a custom application is used.
    * Building the Docker image.
* **Container Registry:**
    * Pushing the Docker image to a container registry (e.g., Docker Hub, GCR, ECR). For this plan, we'll assume Docker Hub for simplicity.
* **Kubernetes Deployment:**
    * Writing Kubernetes manifest files:
        * `Deployment`: To define the desired state of the application, including the number of replicas and the container image to use.
        * `Service`: To expose the application pods via a stable network endpoint. This service will be configured to make the application accessible externally on port 8080.
    * Deploying these manifests to an existing Kubernetes cluster.
* **Verification:**
    * Confirming the application is running correctly within the Kubernetes cluster.
    * Verifying external accessibility on port 8080.
* **Documentation:**
    * This `PLANNING.md` document.
    * A `TASKS.md` document detailing the step-by-step implementation.

**Out of Scope:**

* **Kubernetes Cluster Setup:** This plan assumes an existing, functional Kubernetes cluster is available.
* **CI/CD Pipeline:** Automation of build and deployment processes is not covered.
* **Advanced Security:** Complex security configurations (e.g., NetworkPolicies, PodSecurityPolicies, secrets management beyond basic image pull secrets if needed) are not included.
* **Persistent Storage:** The hello-world application is stateless and does not require persistent storage.
* **Custom Domain & SSL/TLS:** Configuring custom domain names or SSL/TLS certificates for the application.
* **Monitoring & Logging:** Setting up comprehensive monitoring, logging, and alerting solutions (beyond basic `kubectl` commands).
* **High Availability (Beyond Kubernetes Defaults):** Advanced HA configurations beyond what Kubernetes `Deployment` and `Service` objects provide by default.

## 3. Architecture 🏗️

The deployment architecture will involve the following components:

1.  **Hello-World Application Container:**
    * A lightweight web server serving a "Hello, World!" message.
    * Packaged as a Docker image.
2.  **Docker Registry:**
    * A repository (e.g., Docker Hub) to store the application's Docker image.
3.  **Kubernetes Cluster:**
    * **Nodes:** Worker machines where the application pods will run.
    * **Pods:** The smallest deployable units, each running an instance of the application container.
    * **Deployment:** A Kubernetes controller that manages the lifecycle of the application pods, ensuring the desired number of replicas are running and handling updates.
    * **Service (LoadBalancer/NodePort):** A Kubernetes object that provides a stable IP address and port to access the application. It will route traffic to the healthy pods managed by the Deployment. To expose the application externally on port 8080, a `LoadBalancer` type service is preferred if the cluster supports it; otherwise, `NodePort` will be used.

**Flow Diagram:**


+----------------------+     +---------------------+     +---------------------------------+
| Developer/DevOps     |---->| Docker Registry     |---->| Kubernetes Cluster              |
| (App Code, Dockerfile|     | (hello-world-image)|     |                                 |
|  k8s Manifests)      |     +---------------------+     |   +-------------------------+   |
+----------------------+                                 |   | Service (Type: LoadBalancer)|
|   | (Exposes Port 8080)     |   |
|   +-----------+-------------+   |
|               |                 |
|               v                 |
|   +-------------------------+   |
|   | Deployment              |   |
|   | (Manages Pods)          |   |
|   +-------------------------+   |
|   | Pod 1 | Pod 2 | ...     |   |
|   |(App)  | (App) |         |   |
|   +-------------------------+   |
+-----------------|-----------------+
^
| (External Traffic via Port 8080)
|
+---------+---------+
| End User/Client   |
+-------------------+


## 4. Technology Choices 🛠️

* **Application (Example):** `nginxdemos/hello` (a pre-built Nginx image serving a simple page on port 80). This simplifies the Dockerization step for the example. If a custom app were used, choices might include:
    * Language: Python (Flask/Django), Node.js (Express), Go (net/http).
* **Containerization:** Docker
    * `Dockerfile`: Standard Dockerfile syntax.
* **Container Registry:** Docker Hub (public, free tier suitable for this example). Alternatives: Google Container Registry (GCR), Amazon Elastic Container Registry (ECR), Azure Container Registry (ACR), or a private Docker registry.
* **Orchestration:** Kubernetes
    * `kubectl`: The standard Kubernetes command-line tool for interacting with the cluster.
* **Kubernetes API Version:** Standard GA (General Availability) versions for Deployment (`apps/v1`) and Service (`v1`).
* **Service Exposure Method:**
    * **Primary:** `LoadBalancer` service type. This is ideal as it typically provisions an external IP address from the cloud provider (if running on GKE, EKS, AKS, etc.).
    * **Alternative:** `NodePort` service type. If a `LoadBalancer` is not available or practical (e.g., on a local Minikube cluster without a cloud load balancer integration), `NodePort` will expose the service on a static port on each node's IP. Access will then be `<NodeIP>:<NodePort>`. The service will still be configured to listen on port 8080 externally if possible, or the documentation will clarify how the `NodePort` relates to the desired 8080 exposure.

## 5. Success Criteria ✅

* The "hello-world" application is successfully containerized (if a custom app is used) or a pre-built image is correctly identified.
* The Docker image is successfully pushed to and pullable from the chosen container registry.
* Kubernetes `Deployment` and `Service` manifest files are created, are syntactically correct, and adhere to best practices.
* The application is successfully deployed to the Kubernetes cluster without errors.
* The Kubernetes `Deployment` shows the desired number of replicas running and healthy.
* The Kubernetes `Service` is created and, if `LoadBalancer` type, an external IP address is provisioned.
* The application is accessible externally via a web browser or `curl` on port 8080 (or the appropriate `NodePort` if `LoadBalancer` is not used, with clear instructions).
* The deployment is scalable (i.e., the number of replicas can be easily changed via `kubectl scale`).
* The `PLANNING.md` and `TASKS.md` documents are clear, comprehensive, and enable another team member to understand and replicate the deployment.
