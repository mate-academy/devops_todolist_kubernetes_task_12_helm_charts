# Validation Instructions

Follow these steps to validate the deployment and configuration:

1. **Create the kind cluster and deploy the Helm chart**
   - Run the bootstrap script:
     ```sh
     bash helm-charts/todoapp/bootstrap.sh
     ```

2. **Check all resources**
   - To verify all resources, run:
     ```sh
     kubectl get all,cm,secret,ing -A
     ```
   - Or review the `output.log` file in the root of the repository for the output of this command.

3. **Validate Helm chart structure and values**
   - Ensure the following:
     - All resources are created in the correct namespaces (`todoapp` and `mysql`).
     - Resource names are prefixed with their chart name.
     - Secrets are created and populated from values.yaml.
     - StatefulSet and Deployment use values from values.yaml for replicas, image, resources, affinity, tolerations, and PVC.
     - HPA, PV, PVC, and ServiceAccount are present and parameterized.
     - The MySQL sub-chart is deployed as a dependency.

4. **Check pod status**
   - All pods should be in `Running` or `Completed` state:
     ```sh
     kubectl get pods -A
     ```

5. **Troubleshooting**
   - If any resource is missing or not running, check events and logs:
     ```sh
     kubectl describe pod <pod-name> -n <namespace>
     kubectl logs <pod-name> -n <namespace>
     ```

---

