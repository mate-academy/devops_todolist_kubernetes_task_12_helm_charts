#!/bin/bash
set -e

echo "=== Creating kind cluster ==="
kind create cluster --config cluster.yml || true

echo "=== Getting nodes and their labels ==="
kubectl get nodes --show-labels

echo "=== Getting nodes and their taints ==="
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints[*].key}{"\n"}{end}'

echo "=== Tainting nodes with app=mysql label ==="
for node in $(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}'); do
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite || true
done

echo "=== Waiting for nodes to be ready ==="
kubectl wait --for=condition=Ready node --all --timeout=60s

echo "=== Updating helm dependencies ==="
helm dependency build .infrastructure/helm-chart/todoapp

echo "=== Deploying todoapp helm chart ==="
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp -n todoapp --create-namespace

echo "=== Waiting for deployment ==="
kubectl rollout status deployment/todoapp-deployment -n todoapp || kubectl rollout status deployment/todoapp -n todoapp

echo "=== Bootstrap complete! ==="
