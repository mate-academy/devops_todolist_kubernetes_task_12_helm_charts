# Validation Instructions

Follow these steps to validate the changes made to the repository:

## Prerequisites
1. Ensure you have `kubectl`, `helm`, and `kind` installed on your system.
2. Verify that Docker is running.
3. Clone the repository and navigate to its root directory.

## Steps to Validate

1. **Spin up the Kubernetes Cluster**:
    - Use the `kind` configuration file to create a cluster:
      ```bash
      kind create cluster --config cluster.yml
      ```

2. **Inspect Nodes**:
    - Check the nodes for labels and taints:
      ```bash
      kubectl get nodes --show-labels
      kubectl describe nodes
      ```

3. **Taint Nodes**:
    - Taint nodes labeled with `app=mysql`:
      ```bash
      kubectl taint nodes -l app=mysql app=mysql:NoSchedule
      ```

4. **Deploy the Helm Chart**:
    - Run the `bootstrap.sh` script to deploy prerequisites and the `todoapp` Helm chart:
      ```bash
      ./bootstrap.sh
      ```

5. **Verify Deployment**:
    - Check all resources in the cluster:
      ```bash
      kubectl get all,cm,secret,ing -A
      ```

6. **Validate Output**:
    - Compare the output of the above command with the contents of the `output.log` file in the repository. Ensure all resources are created as expected.

7. **Test Application**:
    - Access the ToDo app using the provided ingress URL or NodePort. Verify the application is functional.
    - Test the API endpoints and UI features.

8. **Check Logs**:
    - Inspect the logs of the `todoapp` and `mysql` pods for errors:
      ```bash
      kubectl logs -n todoapp deployment/todoapp
      kubectl logs -n mysql statefulset/mysql
      ```

9. **Validate Horizontal Pod Autoscaler (HPA)**:
    - Ensure the HPA is configured correctly:
      ```bash
      kubectl get hpa -n todoapp
      ```

10. **Clean Up**:
    - Delete the cluster after validation:
      ```bash
      kind delete cluster
      ```

## Notes
- Ensure all configurations in `values.yaml` files are correctly applied.
- Verify that secrets and environment variables are populated as expected.
- Confirm that the `mysql` sub-chart dependencies are resolved and deployed correctly.