Clone repository
clone repository
git clone https://github.com/Foxytail8/devops_todolist_kubernetes_task_12_helm_charts.git
go to folder repository
cd ./devops_todolist_kubernetes_task_12_helm_charts

## PREDEPLOY
if you have cluster - delete it
kind delete cluster

create cluster
kind create cluster --config cluster.yml

## DEPLOY
start file bootstrap
sh ./bootstrap.sh

## TESTING
kubectl get all -n todoapp -o wide
kubectl get all -n mysql -o wide
kubectl get nodes --show-labels
helm list -A

