# Kubernetes App Deployment via Helm

## 📖 Project Overview
This project focuses on the packaging and deployment phase of the Kubernetes lifecycle. It demonstrates the ability to transition from static Kubernetes YAML manifests to dynamic, reusable, and configurable application deployments using **Helm**, the standard package manager for Kubernetes.

## 🛠 Tech Stack & Tools
* **Container Orchestration:** Kubernetes (kind cluster)
* **Package Management:** Helm
* **Application:** Python (Django)

## ⚙️ Implementation Details
The deployment strategy was modernized by implementing Helm charts:
1. **Chart Creation:** Developed a custom Helm chart to package the web application, its required services, and configurations into a single deployable unit.
2. **Templating:** Converted static Kubernetes Deployments and Services into dynamic Helm templates, allowing values to be injected at deployment time.
3. **Reusability:** Centralized configuration parameters within `values.yaml`, making it easy to deploy the application across multiple environments (e.g., dev, staging, prod) without modifying the core manifests.
4. **Validation:** Provided detailed instructions (`INSTRUCTION.md`) for validating the chart installation and verifying the successful rollout of the application pods.

## 📝 Code Review & Approval
This Helm deployment strategy has been reviewed and validated by a Senior DevOps Engineer, ensuring adherence to templating best practices.

You can view the full discussion, implementation details, and final approval in the **[Pull Request #73](https://github.com/mate-academy/devops_todolist_kubernetes_task_12_helm_charts/pull/73)**.
