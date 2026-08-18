# How to validate the changes

This document explains how to verify that the Helm charts deploy the ToDo application and MySQL correctly.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

## 1. Create the kind cluster

From the repository root:

```bash
kind create cluster --config cluster.yml
```

## 2. Inspect nodes and apply the MySQL taint

```bash
kubectl get nodes --show-labels
kubectl describe nodes
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Nodes labeled `app=mysql` must have taint `app=mysql:NoSchedule`. MySQL pods tolerate this taint and use node affinity to land on those nodes. The ToDo app uses node affinity for `app=todoapp`.

## 3. Deploy with bootstrap.sh

`bootstrap.sh` installs ingress-nginx and the `todoapp` Helm chart (which includes the `mysql` subchart):

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Equivalent Helm command:

```bash
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp
```

## 4. Check rendered manifests without a cluster

```bash
helm lint .infrastructure/helm-chart/todoapp
helm template .infrastructure/helm-chart/todoapp -f .infrastructure/helm-chart/todoapp/values.yaml
```

Confirm that:

- resource names are prefixed with the chart name (`todoapp` / `mysql`)
- namespace, secrets, images, resources, rolling update, affinity, HPA, PV/PVC and ServiceAccount come from `values.yaml`
- Secret `data` is generated with a `range` loop
- Deployment environment variables are mapped from secrets with a `range` loop
- `Chart.yaml` lists the `mysql` dependency

## 5. Validate cluster resources

```bash
kubectl get all,cm,secret,ing -A
```

Expected results:

| Check | Expected |
| --- | --- |
| Namespace `mysql` | 2 Running pods named `mysql-0` and `mysql-1` |
| Namespace `todoapp` | at least 2 Running pods named `todoapp-*` |
| HPA | `horizontalpodautoscaler.autoscaling/todoapp` in `todoapp` |
| Ingress | `ingress.networking.k8s.io/todoapp-ingress` in `todoapp` |

Save the command output as `output.log` in the repository root (this is what CI validates).

## 6. Optional application checks

- NodePort: `http://localhost:30007`
- Ingress (after ingress-nginx is ready): `http://localhost/`

```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl describe hpa todoapp -n todoapp
```
