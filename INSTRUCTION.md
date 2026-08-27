# Instructions for checking changes made

## 1. Prerequisites

Make sure you have installed:
- Docker
- kind
- kubectl
- helm

## 2. Deploy everything from scratch

Run the bootstrap script from the repository root. It creates the kind cluster,
taints the mysql-labeled nodes, installs the nginx ingress controller, and
installs the todoapp helm chart.

```bash
./bootstrap.sh
```

## 3. Inspect node labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "Name:|Taints:"
```

You should see the two nodes labeled `app=mysql` tainted with `app=mysql:NoSchedule`,
and the nodes labeled `app=todoapp` untainted.

## 4. View the rendered manifests (with values already substituted)

For the todoapp chart:
```bash
helm template todoapp .infrastructure/helm-chart/todoapp
```

For the mysql sub-chart only:
```bash
helm template todoapp .infrastructure/helm-chart/todoapp/charts/mysql
```

## 5. Lint the chart

```bash
helm lint .infrastructure/helm-chart/todoapp
```

## 6. Check the release history

```bash
helm history todoapp
```

## 7. Validate deployed resources

```bash
kubectl get all,cm,secret,ing -A
```

Expected result:
- Namespace `mateapp` with `todoapp-deployment` (2/2 Ready), `todoapp-service`,
  `todoapp-nodeport`, `todoapp-config`, `todoapp-secret`, `todoapp-hpa`, `todoapp-ingress`
- Namespace `mysql` with `statefulset.apps/mysql` (2/2 Ready), `service/mysql`,
  `configmap/mysql`, `secret/mysql-secrets`
- Both `mysql-0` and `mysql-1` pods running on the two nodes tainted with `app=mysql`

The full output of this command right after deployment is also saved in `output.log`
in the root of this repository.

## 8. Check that the app is reachable

```bash
kubectl get svc -n mateapp
curl http://localhost:30007
```

## 9. Clean up

```bash
helm uninstall todoapp
kind delete cluster --name todoapp-cluster
```
