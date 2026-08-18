#!/bin/bash
set -euo pipefail

CLUSTER_NAME="kind"
CHART_PATH=".infrastructure/helm-chart/todoapp"
RELEASE_NAME="todoapp"

echo "==> Checking kind cluster"
if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Creating kind cluster from cluster.yml"
  kind create cluster --config cluster.yml --name "${CLUSTER_NAME}"
else
  echo "Kind cluster '${CLUSTER_NAME}' already exists"
fi

echo "==> Inspecting nodes (labels and taints)"
kubectl get nodes --show-labels
kubectl describe nodes | grep -E 'Name:|Taints:|Labels:' || true

echo "==> Tainting nodes labeled app=mysql"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "==> Installing ingress-nginx for kind"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "==> Deploying todoapp helm chart (with mysql subchart)"
helm dependency update "${CHART_PATH}" || true
helm upgrade --install "${RELEASE_NAME}" "${CHART_PATH}" --timeout 10m

echo "==> Waiting for mysql and todoapp pods"
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=300s
kubectl wait --for=condition=ready pod -l app=todoapp -n todoapp --timeout=300s

echo "==> Deployment complete"
kubectl get all,cm,secret,ing -A
