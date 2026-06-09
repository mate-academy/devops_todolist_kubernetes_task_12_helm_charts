# Validation Instructions

To validate the deployment of the ToDo application and its MySQL backend, follow these steps:

1. **Verify Cluster and Taints:**
   Check if the node with label `app=mysql` has the correct taint applied:
   ```bash
   kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
   ```
2. Verify Pod Distribution (Affinity & Tolerations):
Ensure that the MySQL pods are running on the tainted node and the todoapp pods are on the normal nodes:
```Bash
kubectl get pods -n todo-apps -o wide
```
3. Check Helm Deployment Status:
```Bash

helm list -n todo-apps
```
4. Review Generated Resources:
Inspect the output.log file in the root directory to ensure all Secrets, ConfigMaps, HPAs, and Deployments are properly generated with the .Chart.Name prefix.