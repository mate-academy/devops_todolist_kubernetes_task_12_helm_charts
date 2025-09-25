# Instructions for Deploying and Validating the TodoApp Helm Chart

This guide explains how to deploy the `todoapp` Helm chart with its MySQL sub-chart and how to validate that all resources are running correctly.

---

## 1. Prerequisites

Make sure you have the following installed:

- Kubernetes cluster (e.g., kind)
- kubectl CLI
- Helm CLI
- yq CLI

---

## 2. Deploy the Chart

Run the bootstrap script to deploy all resources:

./bootstrap.sh
This script will:

Apply ConfigMaps and Secrets.

Create the todoapp namespace if it does not exist.

Update Helm dependencies.

Deploy the todoapp chart (which includes the MySQL sub-chart).

Wait for the deployment to become available.

3. Verify Deployments and StatefulSets
Check the todoapp Deployment:


kubectl get deploy todoapp-todoapp -n todoapp
Check the MySQL StatefulSet:

kubectl get sts todoapp-mysql -n todoapp
4. Verify Services
Check the service for todoapp:


kubectl get svc todoapp-todoapp -n todoapp
Check the MySQL service:


kubectl get svc todoapp-mysql -n todoapp
5. Verify Secrets
List the secrets:


kubectl get secrets -n todoapp
Check that the todoapp-todoapp-secrets and MySQL secrets exist.

6. Verify Persistent Volumes and Claims
List PVs:


kubectl get pv
List PVCs:


kubectl get pvc -n todoapp
7. Logs and Debug
To check logs of the todoapp pod:


kubectl logs -l app=todoapp-todoapp -n todoapp
To check logs of MySQL:


kubectl logs -l app=todoapp-mysql -n todoapp
8. Clean Up
To remove all resources:


helm uninstall todoapp -n todoapp
kubectl delete namespace todoapp