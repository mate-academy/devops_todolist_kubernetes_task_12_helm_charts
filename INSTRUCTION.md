# INSTRUCTION.md

## Validation Instructions

Follow the steps below to validate the deployment of the ToDo application and its MySQL database on the Kubernetes cluster:

### Prerequisites
- Ensure you have [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and configured to access your cluster.
- Ensure [Kind](https://kind.sigs.k8s.io/) is installed on your system.
- Ensure [Helm](https://helm.sh/docs/intro/install/) is installed.

### Steps to Validate

1. **Run the Deployment Script**
   Execute the `bootstrap.sh` script to create the cluster and deploy all required resources:
   ```bash
   ./bootstrap.sh
   ```

2. **Check Cluster Resources**
   After deployment, verify that all resources are created and running:
   ```bash
   kubectl get all -A
   ```

3. **Inspect Helm Releases**
   Verify that the Helm charts are deployed:
   ```bash
   helm list -A
   ```

4. **Access the Application**
   - Check the ingress resource to confirm the external IP or hostname:
     ```bash
     kubectl get ingress -A
     ```
   - Open the application in your browser using the provided URL.

5. **Verify Logs**
   Inspect the logs of the ToDo application pod to ensure it is running without errors:
   ```bash
   kubectl logs -l app=todoapp -n todoapp
   ```

6. **Database Connectivity**
   - Verify that the MySQL service is running:
     ```bash
     kubectl get svc -n mysql
     ```
   - Connect to the MySQL database (replace `<pod-name>` with the actual pod name):
     ```bash
     kubectl exec -it <pod-name> -n mysql -- mysql -u app_user -p
     ```
   - Use `app_user` and the password to login (base64-decoded value from `values.yaml`).

7. **Output Logs**
   Save the output of all resources to the `output.log` file:
   ```bash
   kubectl get all,cm,secret,ing -A > output.log
   ```

### Troubleshooting
- If any pods are not running, describe the pod to see detailed error messages:
  ```bash
  kubectl describe pod <pod-name> -n <namespace>
  ```
- For issues with the ingress controller, check its logs:
  ```bash
  kubectl logs -l app.kubernetes.io/component=controller -n ingress-nginx
  ```

