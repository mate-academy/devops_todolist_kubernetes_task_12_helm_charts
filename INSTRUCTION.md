# Instruction

## 1. Starting the cluster

```bash
kind create cluster --config cluster.yml
```

## 2. Deploying the application

Everything is deployed via the `bootstrap.sh` script. Before running it, grant execute
permissions:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script installs the Ingress controller and Metrics Server, taints the `app=mysql`
nodes, and installs the `todoapp` Helm chart (together with the `mysql` sub-chart).

## 3. Verify everything is up

```bash
kubectl get pods -n todoapp -o wide
kubectl get pods -n mysql -o wide
```

Expected: all pods in `1/1 Running`. The `mysql` pods run on nodes labeled `app=mysql`
(one per node), while the `todoapp` pods run on other nodes.

## 4. Verify scheduling

The `mysql` pods must sit on the tainted `app=mysql` nodes, one per node — toleration,
node affinity and pod anti-affinity at work. The `todoapp` pods run on the remaining
nodes.

## 5. Verify ServiceAccount permissions (RBAC)

```bash
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-reader -n todoapp
```

Expected output: `yes`

## 6. Verify secrets

Secret values are stored in base64. To decode:

```bash
kubectl get secret todoapp-secret -n todoapp -o jsonpath="{.data.DB_PASSWORD}" | base64 -d && echo
```

## 7. Verify the application

```bash
kubectl get svc -n todoapp
```

The application is reachable via NodePort or Ingress.

## 8. Useful Helm commands

```bash
helm list -A                 # list releases
helm history todoapp         # release revision history
helm template todoapp ./helm-chart/todoapp --debug   # render the chart locally
```

## 9. Full resource overview

```bash
kubectl get all,cm,secret,ing -A
```