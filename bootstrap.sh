#!/bin/bash
set -e

kind create cluster --config cluster.yml --name todoapp-cluster

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm dependency update helm-chart/todoapp

helm upgrade --install todoapp helm-chart/todoapp