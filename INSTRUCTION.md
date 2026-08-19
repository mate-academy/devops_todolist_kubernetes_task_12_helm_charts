# TodoApp Helm Chart Instructions

## Deploy

Install Docker, kind, kubectl and Helm.

Run the bootstrap script:
```bash
bash bootstrap.sh
```

## Validate Helm Chart
```bash
helm lint ./helm-chart/todoapp
helm template todoapp ./helm-chart/todoapp
```

## Validate Kubernetes
```bash
kubectl get nodes --show-labels
kubectl get pods -A
kubectl get all,cm,secret,ing -A
```

## Validate MySQL Taint
```bash
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## Validate Helm Release

```bash
helm list -A
kubectl get statefulset -A
kubectl get deployment -A
kubectl get pvc -A
kubectl get hpa -A
```
