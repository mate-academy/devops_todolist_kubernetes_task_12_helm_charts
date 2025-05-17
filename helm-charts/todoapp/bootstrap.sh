#!/bin/bash

# Create kind cluster
kind create cluster --name my-cluster --config cluster.yml

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Taint MySQL nodes
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Update Helm dependencies
cd helm-charts/todoapp
helm dependency update

# Install the chart
helm install todoapp . \
  --namespace todoapp \
  --create-namespace \
  --wait \
  --timeout 5m