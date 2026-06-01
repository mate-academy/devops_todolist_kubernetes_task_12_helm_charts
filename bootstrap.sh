#!/bin/bash

# Taint nodes labeled with app=mysql
kubectl taint nodes $(kubectl get nodes -l app=mysql -o name) app=mysql:NoSchedule

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Deploy todoapp helm chart (includes mysql sub-chart)
helm dependency update .infrastructure/helm-chart/todoapp
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp \
  -f .infrastructure/helm-chart/todoapp/values.yaml \
  -n todoapp \
  --create-namespace
