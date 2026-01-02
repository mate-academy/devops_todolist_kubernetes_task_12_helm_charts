#!/bin/bash
set -e

kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm upgrade --install todoapp-release ./.infrastructure/helm-chart/todoapp --namespace todoapp

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
