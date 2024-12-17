# TodoApp deployment through Helm

## 1. Create a kind cluster:
```bash
kind create cluster --config cluster.yml
```

## 2. Apply taints to MySQL nodes:
```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

## 3. Deploy the app:
```bash
./bootstrap.sh
```
Or
```bash
helm install todoapp .infrastructure/helm-chart/todoapp
```

## 4. Wait 2-3 minutes for pods and services to start, then validate the app:
```bash
kubectl get all,cm,secret,ing -A
```
All pods and services should be ready and running. The app should available in your browser at http://localhost:30007/
