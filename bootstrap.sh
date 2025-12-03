#!/bin/bash
set -euo pipefail

CLUSTER_NAME="todolist"
NAMESPACE="todoapp"

# 1. Создать kind-кластер (если ещё не создан)
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
  kind create cluster --name "$CLUSTER_NAME" --config cluster.yml
fi

# 2. Установить ingress-nginx для kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl -n ingress-nginx wait --for=condition=available deployment/ingress-nginx-controller --timeout=180s

# 3. Проверка лейблов и постановка taint для mysql-нод
kubectl get nodes --show-labels
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite || true

# 4. Установить/обновить зависимости и задеплоить todoapp chart
helm dependency update helm-chart/todoapp

helm upgrade --install todoapp helm-chart/todoapp \
  --namespace "$NAMESPACE" \
  --create-namespace

echo "Deployment finished."
echo "You can check resources with:"
echo "  kubectl get all,cm,secret,ing -A"
