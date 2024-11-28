kind create cluster --config cluster.yml
kubectl taint nodes kind-worker app=mysql:NoSchedule
kubectl taint nodes kind-worker2 app=mysql:NoSchedule

helm install todoapp-release ./infrastructure/helm-chart/todoapp/