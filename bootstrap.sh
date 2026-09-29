#!/bin/bash
set -e

kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

helm upgrade --install todoapp .infrastructure/helm-chart/todoapp