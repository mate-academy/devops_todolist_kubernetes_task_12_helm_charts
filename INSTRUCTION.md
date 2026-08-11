# Validation Instructions for ToDo App Helm Chart

This document provides a step-by-step guide to deploying and validating the ToDo application and its MySQL dependency on a local Kubernetes cluster.

## 1. Environment Provisioning
Initialize the cluster using the provided configuration and apply the required taint to isolate the database nodes from application workloads.

```bash
kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

2. Helm Chart Deployment
Ensure all dependencies (MySQL subchart) are up to date, then deploy the Umbrella chart into an isolated namespace.

```Bash
helm dependency update .infrastructure/helm-chart/todoapp
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp --namespace todoapp --create
```

3. Status Verification (Health Check)
Monitor the deployment pipeline. Wait until all pods (database and application replicas) transition to the Running state and display 1/1 in the READY column.

```Bash
kubectl get pods -n todoapp -w
```

4. Resource Validation
Verify that all Persistent Volumes are correctly bound to their claims, and ensure the configuration maps and secrets have been generated dynamically.

```Bash
kubectl get pvc,cm,secret -n todoapp
```

5. Teardown (Optional)
To cleanly remove the deployment and free up system resources after validation:

```Bash
kind delete cluster
```