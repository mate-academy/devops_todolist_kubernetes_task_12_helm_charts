# 🧱 Kubernetes Helm Deployment for TodoApp + MySQL

This project deploys a **TodoApp** application with a **MySQL** database using **Helm charts** and **Kind (Kubernetes in Docker)**.

Both applications are packaged as Helm charts:
- `helm-chart/todoapp` — main application chart
- `helm-chart/mysql` — MySQL dependency chart

---

## ⚙️ Prerequisites

Before running the setup, make sure you have the following tools installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

You can verify installation with:
```bash
docker --version
kind --version
kubectl version --client
helm version



🚀 Bootstrap Script

The file bootstrap.sh automates cluster setup and Helm deployment.

▶️ How to Run

Make the script executable:

chmod +x bootstrap.sh


Run the bootstrap script:

./bootstrap.sh


Once the script completes, verify the deployment:

kubectl get all,cm,secret,ing -A