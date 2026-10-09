# TodoApp Helm Chart Deployment Guide

## 1. Overview
This project packages the TodoApp and a MySQL database into a modular Helm chart. Following Helm architecture principles, all configurations (resources, affinity, HPA, image tags) are extracted to `values.yaml`, and Kubernetes manifests are generated using Go Templates (`range`, pipes, `nindent`).

## 2. How to Validate Locally

1. **Bootstrap the environment:**
   Run the bootstrap script. This will create the Kind cluster from `cluster.yml`, apply the required `NoSchedule` taint to the MySQL node, install Nginx Ingress, and deploy the application via Helm:
   ```bash
   bash bootstrap.sh
   ```

2. **Verify the Helm Release:**
   Check if the Helm release was installed successfully:
   ```bash
   helm list -n todoapp
   ```

3. **Verify the Node Taint (MySQL):**
   Ensure the taint `app=mysql:NoSchedule` is applied correctly to the specific worker node:
   ```bash
   kubectl describe nodes -l app=mysql | grep Taints
   ```

4. **Verify the Pods and Configuration:**
   Ensure both `todoapp` and `mysql` pods are running successfully:
   ```bash
   kubectl get pods -n todoapp
   ```
   Check the generated `output.log` file in the root directory for a full cluster state dump.

## 3. Production Best Practices Note
While this project demonstrates the core mechanics of Helm (including custom subcharts and Go templating), a real-world enterprise environment would typically adopt the following practices:
* **GitOps:** Instead of running `helm upgrade --install` manually, tools like ArgoCD or FluxCD would be used to pull changes directly from the Git repository.
* **Secrets Management:** Storing base64 secrets in `values.yaml` (even dynamically generated via `range`) is an anti-pattern for production. An External Secrets Operator or Sealed Secrets would be used to fetch credentials from AWS Secrets Manager or HashiCorp Vault.
* **Database Deployments:** While a custom `mysql` subchart is used here for educational purposes, production environments rely on battle-tested charts (e.g., Bitnami) via `helm dependency update` to handle replication, backups, and failovers.