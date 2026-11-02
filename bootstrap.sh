#!/bin/bash

set -e

cd "$(dirname "$0")"

# Create kind cluster if it does not exist
if ! kind get clusters | grep -Fxq "todo-lab"; then
    kind create cluster --name todo-lab --config cluster.yml
fi

# Select kind cluster
kubectl config use-context kind-todo-lab

# Inspect nodes and labels
kubectl get nodes
kubectl get nodes --show-labels
kubectl get nodes -L app

# Inspect existing taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Taint MySQL nodes
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# Verify MySQL taints
kubectl describe nodes -l app=mysql

# Create namespaces
kubectl create namespace mysql --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -

# Install Metrics Server for HPA
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.8.1/components.yaml

# Configure Metrics Server for local kind cluster
if ! kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
    MSYS_NO_PATHCONV=1 kubectl patch deployment metrics-server -n kube-system --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

# Wait for Metrics Server
kubectl rollout status deployment/metrics-server -n kube-system --timeout=240s

# Validate Helm dependencies
helm dependency list ./.infrastructure/helm-chart/todoapp

# Validate Helm chart
helm lint ./.infrastructure/helm-chart/todoapp

# Deploy TodoApp and MySQL using Helm
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp --namespace todoapp --wait --timeout 10m

# Verify Helm release
helm list -A
helm status todoapp -n todoapp

# Verify Kubernetes resources
kubectl get pods -A -o wide
kubectl get deployments -n todoapp
kubectl get statefulsets -n mysql
kubectl get services -A
kubectl get pv,pvc -A
kubectl get hpa -n todoapp

# Save results to output.log
kubectl get all,cm,secret,ing -A > output.log

echo "completed!"


# Install Ingress Controller
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
