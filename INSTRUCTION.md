# INSTRUCTION — how to validate the changes

Prerequisites: `kind`, `kubectl`, `helm` installed; cluster created and chart deployed via `./bootstrap.sh`.

## 1. Nodes: labels and taints

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels,TAINTS:.spec.taints
```

Expected:
- `todoapp-worker`, `todoapp-worker2` — label `app=mysql` **and** taint `app=mysql:NoSchedule`
- `todoapp-worker3` … `todoapp-worker6` — label `app=todoapp`, no taints

## 2. Helm release

```bash
helm list -A
```

Expected: release `todoapp`, STATUS `deployed`.

## 3. All deployed resources

```bash
kubectl get all,cm,secret,sa,rolebinding -A
kubectl get pv,pvc
```

Expected:
- namespace `todoapp`: deployment `todoapp` (2 replicas), services `todoapp-service` (ClusterIP) and `todoapp-nodeport` (NodePort 30007), configmap `todoapp-config`, secret `todoapp-secret`, serviceaccount `secrets-reader`, rolebinding `todoapp-rb`
- namespace `mysql`: statefulset `mysql` (2 replicas) with pods `mysql-0` and `mysql-1`, headless service `mysql`, secret `mysql-secret`
- PV `todoapp-pv` and PVC `todoapp-pvc` (namespace `todoapp`), plus `mysql-data-mysql-0` and `mysql-data-mysql-1` (namespace `mysql`) — all **Bound**

## 4. Pod placement (affinity + toleration)

```bash
kubectl get pods -A -o wide | grep -E 'mysql-0|todoapp-'
```

Expected:
- `mysql-0` runs on `todoapp-worker` or `todoapp-worker2` — the only nodes it tolerates (required node affinity + toleration for `app=mysql:NoSchedule`)
- `todoapp-*` pods run on `todoapp-worker3`…`todoapp-worker6` — they carry no toleration, so the taint keeps them off the mysql nodes

## 5. HPA

```bash
kubectl get hpa -n todoapp
```

Expected: hpa `todoapp` targeting `Deployment/todoapp`, MINPODS `2`, MAXPODS `5`, CPU/memory utilization targets `70%`.

## 6. The app works

Port 30007 is mapped to the host by `cluster.yml`, and the NodePort service uses it:

```bash
curl http://localhost:30007/api/health   # health endpoint → 200
curl http://localhost:30007/             # landing page HTML
curl http://localhost:30007/api/         # API listing
```

## 7. Secrets are controlled from values.yaml

```bash
kubectl get secret -n todoapp todoapp-secret -o jsonpath='{.data.DB_HOST}' | base64 -d
# mysql-0.mysql.mysql.svc.cluster.local
kubectl get secret -n mysql mysql-secret -o jsonpath='{.data.MYSQL_DATABASE}' | base64 -d
# app_db
```

Values match `.infrastructure/helm-chart/todoapp/values.yaml` and `.infrastructure/helm-chart/todoapp/charts/mysql/values.yaml`. Change a value there and re-run `./bootstrap.sh` to see it propagate.

## 8. output.log

`kubectl get all,cm,secret,ing -A > output.log` was captured in the repository root — review it for the full inventory of resources.
