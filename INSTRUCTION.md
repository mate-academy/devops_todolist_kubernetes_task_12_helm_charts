create cluster
```bash
kind create cluster --config cluster.yml
```

Added taings for nodes with app=mysql label
```bash
kubectl taint nodes $(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}') app=mysql:NoSchedule
```

Install app with helm
```bash
helm install todoapp-release .infrastructure/helm-chart/todoapp
```

Check 1. Helm list with app, 2. Pods for todoapp namespace, 3. Pods for mysql namespace
```bash
helm list -A
kubectl get pods -n mysql
kubectl get pods -n todoapp
```

Open browser in: http://localhost