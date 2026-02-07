# ToDo App Helm Deployment

This repository contains a Helm chart configuration to deploy a Python ToDo application with a MySQL database on a Kind Kubernetes cluster.

## Prerequisites
- Docker
- Kind
- Helm
- Kubectl

## 1. Deployment
To spin up the cluster, taint the nodes, and deploy the application, run the bootstrap script:

```
chmod +x bootstrap.sh
./bootstrap.sh
```
## 2. Validation
Check Pod Placement (Taints & Affinity)
Ensure that the MySQL pod is running on the tainted node (kind-worker) and the ToDo App is running on a different node:

```
kubectl get pods -n todo-ns -o wide
```
### Access the Application
To access the web interface, forward the service port to your local machine:

```
kubectl port-forward svc/todoapp-service 8080:80 -n todo-ns
```
Then open your browser at: http://localhost:8080

### Check Created Resources
A snapshot of all created resources (ConfigMaps, Secrets, Ingress, etc.) can be found in the generated log file:

output.log