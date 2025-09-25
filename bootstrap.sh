#!/bin/bash
set -e

# ==================================================
# Bootstrap script for deploying todoapp Helm chart
# ==================================================

echo "==> Applying ConfigMaps and Secrets"
kubectl apply -f .infrastructure/confgiMap.yml
kubectl apply -f .infrastructure/secret.yml

echo "==> Creating namespace 'todoapp' if not exists"
kubectl create namespace todoapp || true

echo "==> Updating Helm dependencies"
cd .infrastructure/helm-chart/todoapp
helm dependency update
cd -

echo "==> Installing/upgrading todoapp chart"
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp \
  --create-namespace \
  --namespace "$(yq e '.namespace' .infrastructure/helm-chart/todoapp/values.yaml)"

echo "==> Waiting for todoapp Deployment to be available"
kubectl wait --for=condition=available deployment/todoapp-todoapp \
  -n "$(yq e '.namespace' .infrastructure/helm-chart/todoapp/values.yaml)" \
  --timeout=120s || true

echo "==> Waiting for MySQL StatefulSet to be ready"
kubectl wait --for=condition=ready pod -l app=todoapp-mysql \
  -n "$(yq e '.namespace' .infrastructure/helm-chart/todoapp/values.yaml)" \
  --timeout=120s || true

echo "==> Deployment complete"
