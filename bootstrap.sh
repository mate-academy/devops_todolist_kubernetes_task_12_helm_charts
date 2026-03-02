#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="todoapp-cluster"
CHART_PATH=".infrastructure/helm-chart/todoapp"
VALUES_FILE="${CHART_PATH}/values.yaml"

if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml
fi

kubectl cluster-info

# Inspect labels and taints before changes.
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Taint mysql nodes.
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# Inspect labels and taints after changes.
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Install ingress controller required by the chart ingress resource.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pods \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

helm dependency build "${CHART_PATH}"
helm upgrade --install todoapp "${CHART_PATH}" -f "${VALUES_FILE}"

kubectl get all,cm,secret,ing -A | tee output.log
