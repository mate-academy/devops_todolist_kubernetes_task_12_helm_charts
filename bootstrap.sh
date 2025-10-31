#!/bin/bash

set -e

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml

# Deploy todoapp helm chart
kind get clusters | grep -q "kind" || kind create cluster --name kind --wait 60s --config ./cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
kubectl get ns todoapp > /dev/null 2>&1 || kubectl create namespace todoapp
helm dependency update ./.infrastructure/helm-chart/todoapp
helm upgrade --install todoapp-release ./.infrastructure/helm-chart/todoapp -n todoapp --create-namespace