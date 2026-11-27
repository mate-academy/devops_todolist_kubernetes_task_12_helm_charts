# TodoApp Deployment and Validation Guide

## 1. Overview

This repository deploys a Django TodoApp application and MySQL 8.0 to a local Kubernetes cluster created with **kind**. Deployment is managed with Helm:

- **Parent chart:** `.infrastructure/helm-chart/todoapp`
- **MySQL subchart:** `.infrastructure/helm-chart/todoapp/charts/mysql`
- **Helm release:** `todoapp-release`
- **Application namespace:** `todoapp` (configured in the parent chart's `values.yaml`)
- **Database namespace:** `mysql` (configured in the MySQL subchart's `values.yaml`)

The chart creates the application Deployment, Services, ConfigMap, Secret, HorizontalPodAutoscaler, PersistentVolume, PersistentVolumeClaim, Ingress, and RBAC resources, as well as the MySQL StatefulSet and its supporting resources.

**Run all commands in this guide from the repository root.**

## 2. Prerequisites

Install and start the following tools:

- Docker Desktop (or another working Docker engine)
- `kind`
- `kubectl`
- `helm`
- Bash

Check the installation:

```bash
docker info
kind version
kubectl version --client
helm version
```

## 3. Create and inspect the Kubernetes cluster

Create the cluster with the repository's `cluster.yml` configuration:

```bash
kind create cluster --name todoapp-helm --config cluster.yml
kubectl config use-context kind-todoapp-helm
kubectl get nodes -o wide
```

If `todoapp-helm` already exists, **do not create it again**; select its context instead:

```bash
kubectl config use-context kind-todoapp-helm
```

Inspect node labels and taints:

```bash
kubectl get nodes -L app
kubectl describe nodes | grep -E '^(Name:|Taints:)'
```

The supplied `cluster.yml` labels two worker nodes with `app=mysql` and three worker nodes with `app=todoapp`. Confirm those labels in the output. Add the required taint to all MySQL nodes:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

This taint restricts scheduling on the MySQL nodes to Pods with the corresponding toleration. The MySQL subchart sets that toleration and uses node affinity. The application chart has its own node affinity settings.

## 4. Review Helm configuration

The main configuration files are:

| File | Configuration |
| --- | --- |
| `.infrastructure/helm-chart/todoapp/values.yaml` | Application namespace, image, Secrets, resource requests/limits, rolling updates, node affinity, HPA, PV/PVC, ServiceAccount |
| `.infrastructure/helm-chart/todoapp/charts/mysql/values.yaml` | MySQL namespace, image, replicas, Secrets, resource requests/limits, storage, affinity, tolerations |

The chart names Kubernetes resources using `.Chart.Name` and chart-derived names. Namespace values are read from the corresponding `values.yaml` files.

### Database settings

The application's `secrets` values must match the MySQL configuration:

| TodoApp variable | Description |
| --- | --- |
| `DB_NAME` | MySQL database name; the sample database is `app_db` |
| `DB_USER` | Must match the MySQL `MYSQL_USER` value |
| `DB_PASSWORD` | Must match the MySQL `MYSQL_PASSWORD` value |
| `DB_HOST` | Hostname of the database service or an individual MySQL Pod |
| `SECRET_KEY` | Django application secret |

The current example configuration uses `mysql.mysql.svc.cluster.local` for `DB_HOST`. This is the MySQL headless Service name. **The two MySQL StatefulSet replicas are not configured for database replication**, so they must not be treated as an interchangeable replicated database. For a single stable target in this local exercise, set `DB_HOST` to `mysql-0.mysql.mysql.svc.cluster.local` and ensure the database and credentials are initialized there.

**Security:** The sample passwords in this training chart are not production credentials. Never commit real passwords, tokens, or Django secret keys to a public repository. Use an appropriate Secret-management solution for production deployments.

## 5. Validate the Helm charts

From the repository root, refresh the local chart dependency, run Helm lint, and render the manifests:

```bash
helm dependency update ./.infrastructure/helm-chart/todoapp
helm lint ./.infrastructure/helm-chart/todoapp
helm template todoapp-release ./.infrastructure/helm-chart/todoapp \
  -f ./.infrastructure/helm-chart/todoapp/values.yaml > /tmp/todoapp-rendered.yaml
```

`helm lint` should report `0 chart(s) failed`. `helm template` should exit successfully and create `/tmp/todoapp-rendered.yaml`. The rendered output includes resources from both the `todoapp` parent chart and the `mysql` subchart.

Do not publish the rendered file without reviewing it: Kubernetes Secret resources contain base64-encoded values, which are **not encrypted**.

## 6. Deploy the application

### Option A: Automated deployment

Check the bootstrap script and run it:

```bash
bash -n bootstrap.sh
bash bootstrap.sh
```

The bootstrap workflow is intended to:

1. Create the `todoapp-helm` cluster from `cluster.yml` if it does not already exist, and select its Kubernetes context.
2. Inspect node labels and taints, then taint the `app=mysql` nodes.
3. Install the NGINX Ingress Controller and wait for its Deployment.
4. Install Metrics Server for HPA metrics (with a local kind-specific kubelet TLS adjustment).
5. Update the MySQL chart dependency, run `helm lint`, and validate rendered manifests with `helm template`.
6. Install or upgrade the `todoapp-release` Helm release.
7. Report Kubernetes resources and save the cluster inventory in `output.log`.

**Note:** Ensure `bootstrap.sh` contains the `helm template` validation command from section 5 before submitting the task. Shell continuation backslashes (`\`) must be the **last character on their lines**, with no trailing spaces.

### Option B: Manual Helm installation

If the kind cluster, node configuration, NGINX Ingress Controller, and Metrics Server are already prepared, use:

```bash
helm dependency update ./.infrastructure/helm-chart/todoapp
helm lint ./.infrastructure/helm-chart/todoapp
helm template todoapp-release ./.infrastructure/helm-chart/todoapp \
  -f ./.infrastructure/helm-chart/todoapp/values.yaml > /tmp/todoapp-rendered.yaml
helm upgrade --install todoapp-release ./.infrastructure/helm-chart/todoapp \
  --namespace default \
  --wait \
  --timeout 20m
```

The Helm release is installed in `default`, but the resources in the parent and subcharts are placed in their configured application and database namespaces.

The initial installation may take additional time while Docker images are downloaded. A timeout does not necessarily mean that all created resources failed. Inspect their status before retrying.

## 7. Verify the deployment

Run:

```bash
helm status todoapp-release
kubectl get pods -n todoapp -o wide
kubectl get pods -n mysql -o wide
kubectl get svc -n todoapp
kubectl get svc -n mysql
kubectl get ingress -n todoapp
kubectl get hpa -n todoapp
kubectl get pvc -A
```

Expected results:

- `helm status` reports `STATUS: deployed`.
- TodoApp Pods reach `1/1 Running` and become Ready.
- MySQL Pods reach `1/1 Running`.
- The TodoApp Ingress, HPA, Services, and storage resources exist.

The application exposes `/api/health` and `/api/ready`. The readiness endpoint intentionally returns HTTP 500 during roughly the first 30 seconds after application startup, before returning HTTP 200. Readiness failures during this period are expected; persistent failures require investigation.

## 8. Generate `output.log`

After the application is ready, save the Kubernetes resource inventory required by the assignment:

```bash
kubectl get all,cm,secret,ing -A > output.log
ls -lh output.log
```

This command includes resources from all namespaces. The output shows the names and metadata of Secret resources, not their plaintext values. Confirm that resources from both `todoapp` and `mysql` appear in the file.

## 9. Troubleshooting

Check Pods, events, and application logs:

```bash
kubectl get pods -A
kubectl describe deployment todoapp -n todoapp
kubectl logs -n todoapp deployment/todoapp --tail=100
kubectl get events -n todoapp --sort-by=.lastTimestamp
kubectl get events -n mysql --sort-by=.lastTimestamp
```

Common issues include incorrect database hostnames or credentials, initialization/migration problems, image pulls, Pending PVCs, and health probes that run before Django is ready. If a Pod is restarting, use `kubectl logs -n todoapp <pod-name> --previous` to inspect its previous container logs. Avoid deleting the database or PVCs while diagnosing the issue.

For a failed GitHub Actions check, verify that the chart is located at the **exact path** `.infrastructure/helm-chart/todoapp` and that the MySQL dependency exists at `charts/mysql` inside it. Re-run the commands in section 5 locally.

## 10. Update or uninstall the release

After changing chart configuration:

```bash
helm upgrade todoapp-release ./.infrastructure/helm-chart/todoapp
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
```

To uninstall the release:

```bash
helm uninstall todoapp-release --namespace default
```

**Warning:** Removing the Helm release, persistent storage, or the kind cluster may affect stored data. Do not delete PVCs or the cluster unless you intentionally want to remove the environment.

## 11. Project structure

```text
.
├── .infrastructure/
│   └── helm-chart/
│       └── todoapp/
│           ├── Chart.yaml
│           ├── values.yaml
│           ├── templates/
│           └── charts/
│               └── mysql/
│                   ├── Chart.yaml
│                   ├── values.yaml
│                   └── templates/
├── bootstrap.sh
├── cluster.yml
├── INSTRUCTION.md
└── output.log
```
