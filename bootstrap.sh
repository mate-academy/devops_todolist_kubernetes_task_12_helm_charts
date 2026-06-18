#!/bin/bash


# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

for node in $(kubectl get nodes -l app=mysql -o name); do
  kubectl taint "$node" app=mysql:NoSchedule
done

helm install todoapp .infrastructure/helm-chart/todoapp
