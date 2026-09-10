# Validation instructions

## Render and lint locally

Run these commands from the repository root:

```bash
helm dependency build helm-chart/todoapp
helm lint helm-chart/todoapp
helm template todoapp helm-chart/todoapp > /tmp/todoapp.yaml
kubectl apply --dry-run=client -f /tmp/todoapp.yaml
```

Check the rendered output for the `todoapp` Deployment, HPA, PV/PVC, RBAC objects,
Ingress, and the `mysql` StatefulSet. Confirm that the application and MySQL
Secrets contain the expected keys and that the Deployment and StatefulSet read
their environment variables from those Secrets.

## Deploy to kind

The complete workflow is in `bootstrap.sh`:

```bash
bash bootstrap.sh
kubectl get all,cm,secret,ing -A
```

The final command is also captured in `output.log`. To reach the application
locally, add `127.0.0.1 todoapp.local` to the hosts file and browse to
`http://todoapp.local` after the ingress controller is ready.

## Inspect scheduling

```bash
kubectl get nodes --show-labels
kubectl get nodes -l app=mysql
kubectl describe nodes | grep -A3 Taints
kubectl -n todoapp get pods -o wide
```

MySQL nodes are labeled `app=mysql`, tainted `app=mysql:NoSchedule`, and selected
by the MySQL chart's affinity and toleration values. The application nodes use
the corresponding `app=todoapp` affinity.