#!/bin/bash


# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Install the Todoapp and MySQL Helm charts
helm install todoapp-release .