# ToDo App Helm Chart: deployment and validation

## Prerequisites

- Docker
- [kind](https://kind.sigs.k8s.io/)
- kubectl
- Helm 3

## Chart layout

```
helm-chart/todoapp/
├── Chart.yaml              # declares the dependency on the mysql sub-chart
├── values.yaml             # namespace, image, secrets, resources, rollingUpdate,
│                           # affinity, hpa, pv/pvc, serviceAccount, ...
├── templates/              # namespace, secret, configmap, pv, pvc, rbac,
│                           # deployment, hpa, services, ingress
└── charts/
    └── mysql/
        ├── Chart.yaml
        ├── values.yaml     # namespace, replicas, image, secrets, storage,
        │                   # resources, tolerations, affinity
        └── templates/      # namespace, secret, configmap, service, statefulset
```

Notes:
- The chart lives in the repository-root `helm-chart/todoapp` directory.
  `.infrastructure/helm-chart` is a symlink to `../helm-chart`, so the course CI
  (`.github/workflows/validate-helm-chart.yml`) still finds the chart at its expected path.
- Namespaces are rendered as `<.Chart.Name>-<values.namespace>`:
  `todoapp-todoapp` for the app and `mysql-mysql` for MySQL
  (`DB_HOST` is `mysql-0.mysql.mysql-mysql.svc.cluster.local`).

## Deploy

Run from the repository root:

```bash
./bootstrap.sh
```

The script:

1. Creates a kind cluster from `cluster.yml` (skipped if a cluster named `kind` already exists).
2. Prints node labels and taints.
3. Taints the nodes labeled `app=mysql` with `app=mysql:NoSchedule`.
4. Installs the ingress-nginx controller and waits for it to become ready.
5. Installs the `todoapp` Helm release (the `mysql` sub-chart comes with it).
6. Writes `kubectl get all,cm,secret,ing -A` to `output.log`.

## Validate

1. Lint and render the chart:
   ```bash
   helm lint helm-chart/todoapp
   helm template helm-chart/todoapp -f helm-chart/todoapp/values.yaml
   ```
2. Check the release:
   ```bash
   helm list
   ```
3. Check the taints on the mysql nodes:
   ```bash
   kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
   ```
4. Check the workloads. You should see 2 `mysql-*` pods (one on each `app=mysql` node) and 2 `todoapp-*` pods, all `Running`:
   ```bash
   kubectl get pods -n mysql-mysql -o wide
   kubectl get pods -n todoapp-todoapp -o wide
   kubectl get hpa,ing,pvc -n todoapp-todoapp
   ```
5. Open the app:
   - Ingress: http://localhost/
   - NodePort: http://localhost:30007/
   - Health check: `curl http://localhost:30007/api/health`
6. Run the same output check that CI runs:
   ```bash
   python3 .github/workflows/scripts/validate-output.py
   ```

## Change values

Any value can be overridden at install time, for example:

```bash
helm upgrade --install todoapp helm-chart/todoapp --set hpa.maxReplicas=8 --set image.tag=4.0.1 --set mysql.replicas=2
```

## Cleanup

```bash
helm uninstall todoapp
kind delete cluster --name kind
```
