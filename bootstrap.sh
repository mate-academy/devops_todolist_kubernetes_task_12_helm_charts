#!/bin/bash

# Create kind cluster if it doesn't exist
if ! kind get clusters | grep -q "kind"; then
  echo "Creating kind cluster..."
  kind create cluster --config cluster.yml
fi

# Install Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Update dependencies for todoapp chart
echo "Updating Helm dependencies..."
helm dependency update helm-chart/todoapp

# Install todoapp chart
echo "Installing todoapp Helm chart..."
helm install todoapp helm-chart/todoapp

# Wait for all resources to be ready
echo "Waiting for all resources to be ready..."
NAMESPACE=${1:-todoapp}
kubectl wait --for=condition=Available deployment/todoapp --timeout=120s -n "$NAMESPACE"

# Get all resources and save to output.log
echo "Getting all resources and saving to output.log..."
kubectl get all,cm,secret,ing -A > output.log
