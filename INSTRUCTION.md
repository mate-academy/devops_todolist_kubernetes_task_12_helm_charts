
# How to Validate the Deployment
## Create cluster:
kind create cluster --config ./cluster.yml
## after that:
kubectl kubectl get nodes --show-labels
kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule
## How to install Helm Chart:
helm dependency update ./todoapp
helm install todoapp ./todoapp
# How to validate :
##  How to check the Helm chart:
helm list -A
##  Check if MySQL and ToDo App pods are running:
kubectl get pods -n todoapp
kubectl get pods -n mysql
## How to validate all changhes:
kubectl get all,cm,secret,ing -A > output.log

