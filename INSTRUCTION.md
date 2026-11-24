# Validation instructions

Requirements: Docker, `kind`, `kubectl`, `helm`; ports 80 and 443 free.
Run all commands from the repository root.

## 1. Check the chart without a cluster

```bash
helm lint .infrastructure/helm-chart/todoapp
helm template todoapp-release .infrastructure/helm-chart/todoapp > /dev/null
helm template todoapp-release .infrastructure/helm-chart/todoapp --set todoapp.hpa.maxReplicas=8 | grep maxReplicas
```

Expected: lint reports `0 chart(s) failed`, the render succeeds, and the last command prints `maxReplicas: 8` (the value comes from `values.yaml`).

## 2. Deploy

```bash
bash bootstrap.sh
```

This creates the `todoapp` kind cluster from `cluster.yml`, taints the `app=mysql` nodes, installs ingress-nginx and metrics-server, and deploys the `todoapp` chart with its `mysql` sub-chart. It takes about 10 minutes. Wait 1-2 minutes after it finishes before checking.

## 3. Validate

| # | Command | Expected result |
|---|---------|-----------------|
| 1 | `kubectl describe nodes \| grep -E "^Name:\|Taints:"` | `app=mysql:NoSchedule` only on the two workers labeled `app=mysql` |
| 2 | `kubectl get pods -A` | All pods `Running`: `mysql-0` and `mysql-1` in `mysql-mysql`, 2 `todoapp` pods in `todoapp-todoapp` |
| 3 | `kubectl get pods -n mysql-mysql -o wide` | Both mysql pods run on nodes labeled `app=mysql` |
| 4 | `kubectl get pv,pvc -A` | `todoapp-pv-data` is `Bound` to `todoapp-pvc-data`; `data-mysql-0` and `data-mysql-1` are `Bound` |
| 5 | `kubectl get hpa -n todoapp-todoapp` | MINPODS 2, MAXPODS 5, CPU and memory show percentages of 70%, not `<unknown>` |
| 6 | `kubectl auth can-i get secrets -n todoapp-todoapp --as=system:serviceaccount:todoapp-todoapp:todoapp-secrets-reader` | `yes` |
| 7 | `kubectl exec -n mysql-mysql mysql-0 -- mysql -uapp_user -p1234 app_db -e "SHOW TABLES;"` | Django tables are listed |
| 8 | `curl -i http://localhost/api/health` | `HTTP/1.1 200` |

Open http://localhost/ to see the app. Without the ingress, use `kubectl port-forward -n todoapp-todoapp svc/todoapp-service 8080:80` and open http://localhost:8080.

The `todoapp` pods may show 2-3 restarts shortly after the first start, because the app starts before MySQL finishes initializing. The restart count must stay stable afterwards.

## 4. Clean up

```bash
helm uninstall todoapp-release -n default
kind delete cluster --name todoapp
```
