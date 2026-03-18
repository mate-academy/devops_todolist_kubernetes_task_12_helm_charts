#!/bin/bash
kubectl apply -f .infrastructure/app/metrics-server.yml

kubectl apply -f .infrastructure/app/pv.yml
helm install todoapp .infrastructure/helm-chart/todoapp
# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
