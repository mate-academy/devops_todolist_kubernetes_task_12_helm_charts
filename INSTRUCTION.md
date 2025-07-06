# Instructions to Validate the todoapp Helm Chart Deployment

## Prerequisites

- Kubernetes cluster created with `kind` (Kubernetes IN Docker)
- `kubectl` CLI installed and configured to access your kind cluster
- `helm` CLI installed

## Steps to Deploy and Validate

1. **Deploy prerequisites and the todoapp Helm chart**

   Run the provided bootstrap script that contains all necessary commands to deploy the prerequisites and the todoapp Helm chart (including the mysql sub-chart):

   ```bash
   ./bootstrap.sh
   ```

2. **Verify deployment status**

   After the script completes, verify that all resources are deployed correctly by running:

   ```bash
   kubectl get all,cm,secret,ing -A
   ```

3. **Check output**

   The output of the above command should be saved in the `output.log` file located at the root of the repository.

   Verify that:

   - All namespaces are created as defined in `values.yaml`
   - Secrets are created and populated as expected
   - Deployments are using image repositories and tags defined in `values.yaml`
   - RollingUpdate parameters are set correctly
   - Resource requests and limits match those specified in `values.yaml`
   - Node affinity and tolerations are applied
   - Horizontal Pod Autoscaler (HPA) is configured with min/max replicas and CPU/Memory utilization as per `values.yaml`
   - Persistent Volume Claims (PVC) have the requested storage capacity
   - Service Account names in deployment and RBAC objects match the `values.yaml` setting

4. **Validate MySQL sub-chart**

   - Confirm that the mysql StatefulSet is deployed with the correct number of replicas
   - Check PVC storage requests and resource limits
   - Verify affinity and toleration parameters are applied as configured
   - Confirm secrets are populated via range function and mounted properly

5. **Test application**

   (Optional) You may test the todoapp application to ensure it is running as expected.

## Notes

- All configurable parameters (namespace, secrets, images, replicas, storage, affinity, tolerations, HPA, etc.) are controlled via the `values.yaml` files in both the root chart and the mysql sub-chart.
- The charts use `.Chart.Name` as a prefix for all resource names to avoid conflicts.
- Secrets are populated using a `range` function in Helm templates.
- Dependencies between todoapp and mysql charts are defined explicitly in `Chart.yaml`.

---

If you encounter any issues, please check logs of pods with:

```bash
kubectl logs <pod-name> -n <namespace>
```

And verify the events with:

```bash
kubectl get events -A
```

---
