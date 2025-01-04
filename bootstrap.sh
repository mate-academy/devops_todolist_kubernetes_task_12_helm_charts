#!/bin/bash
set -e

echo "Creating Kind cluster..."
kind create cluster --config=cluster.yml

echo "Installing ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Deploying Helm chart for MySQL..."
helm dependency update ./helm-chart/todoapp
helm install mysql ./helm-chart/todoapp/charts/mysql

echo "Deploying Helm chart for ToDo App..."
helm install todoapp ./helm-chart/todoapp

echo "Deployment completed successfully!"
