# Helm chart validation

From the repository root:

```bash
kind create cluster --config cluster.yml
kubectl get nodes --show-labels
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
bash bootstrap.sh
```

Validate the chart and rendered resources:

```bash
helm lint ./helm-chart/todoapp
helm template todoapp ./helm-chart/todoapp
kubectl get all,cm,secret,ing -A
helm test todoapp
```

Open the application at `http://localhost/`. The kind cluster maps host port 80 to
the control-plane node, and the bootstrap script schedules ingress-nginx on that node.