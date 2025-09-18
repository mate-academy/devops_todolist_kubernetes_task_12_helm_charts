#!/bin/bash

# Install Kind
kind create cluster --config cluster.yml

# Install Kind
kind create cluster --config cluster.yml

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Deploy Helm Chart an Dependencies
helm dependency build
helm upgrade todoapp helm-chart/todoapp -n default

# Deploy Helm Chart an Dependencies
helm upgrade todoapp helm-chart/todoapp -n default
helm dependency build