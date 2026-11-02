## Cluster setup
```bash
kind create cluster --name todo-lab --config cluster.yml
```
Apply MySQL taints:
```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```
```bash
kubectl describe nodes -l app=mysql
```
## Validate Helm charts
```bash
helm dependency list ./.infrastructure/helm-chart/todoapp
helm lint ./.infrastructure/helm-chart/todoapp
helm lint ./helm-chart/todoapp/charts/mysql
helm template todoapp ./.infrastructure/helm-chart/todoapp --namespace todoapp
```
## Deploy
```bash
bash bootstrap.sh
```
## Validate Helm release
```bash
helm list -A
helm status todoapp -n todoapp
```
## Validate MySQL
```bash
kubectl get statefulsets -n mysql
kubectl get pods -n mysql -o wide
kubectl get svc -n mysql
```
## Validate storage
```bash
kubectl get pv
kubectl get pvc -A
```
## Check logs
```bash
kubectl logs deployment/todoapp-deployment -n todoapp
kubectl logs mysql-statefulset-0 -n mysql
```
