#!/bin/bash
set -e

# Create kind cluster from cluster.yml
kind create cluster --name todolist --config cluster.yml


# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Build/update dependencies for the Helm chart
helm dependency update .infrastructure/helm-chart/todoapp

helm lint .infrastructure/helm-chart/todoapp

helm upgrade --install todoapp .infrastructure/helm-chart/todoapp

LC_ALL=C.UTF-8 kubectl get all,cm,secret,ing -A > output.log