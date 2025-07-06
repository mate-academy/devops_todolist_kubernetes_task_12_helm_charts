#!/bin/bash
set -e

NAMESPACE="todoapp"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Update Helm dependencies (mysql subchart)
helm dependency update ./helm-chart/todoapp

# Install or upgrade todoapp Helm chart (with mysql subchart)
helm upgrade --install todoapp ./helm-chart/todoapp --namespace "$NAMESPACE" --wait

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

