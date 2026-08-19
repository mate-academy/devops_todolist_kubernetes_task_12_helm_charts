#!/bin/bash

#!/bin/bash

kind create cluster --config cluster.yml

kubectl get nodes --show-labels

kubectl label nodes -l app=mysql app=mysql --overwrite
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

kubectl apply -f .infrastructure/security/rbac.yml

helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp

kubectl get all,cm,secret,ing -A