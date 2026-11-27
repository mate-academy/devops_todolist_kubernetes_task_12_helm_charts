#!/bin/bash
set -e

# Select Kubernetes cluster
kubectl config use-context kind-todoapp-helm

# Configure MySQL node taints
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for Ingress Controller
kubectl rollout status deployment/ingress-nginx-controller \
  -n ingress-nginx --timeout=300s

# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Configure Metrics Server for local kind cluster
if ! kubectl get deployment metrics-server -n kube-system \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl patch deployment metrics-server -n kube-system --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

# Update Helm dependencies
helm dependency update ./helm-chart/todoapp

# Validate Helm Chart
helm lint ./helm-chart/todoapp

# Deploy Django and MySQL using Helm
helm upgrade --install todoapp-release ./helm-chart/todoapp \
  --namespace default \
  --wait \
  --timeout 10m

# Verify resources
kubectl get pods -n todoapp
kubectl get pods -n mysql
kubectl get ingress -n todoapp

echo "Helm deployment completed successfully."