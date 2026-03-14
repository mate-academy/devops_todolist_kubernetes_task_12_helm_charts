#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-kind}"
RELEASE_NAME="${RELEASE_NAME:-todoapp}"
NAMESPACE="${NAMESPACE:-todoapp}"
CHART_PATH="${ROOT_DIR}/helm-chart/todoapp"

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/cluster.yml"
fi

kubectl wait --for=condition=Ready node --all --timeout=240s

echo "=== Node labels ==="
kubectl get nodes -o wide --show-labels

echo "=== Node taints (before) ==="
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "=== Node taints (after) ==="
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Prerequisite for ingress resources on kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait until ingress controller and admission jobs are ready before creating Ingress resources.
kubectl -n ingress-nginx wait --for=condition=complete --timeout=240s job/ingress-nginx-admission-create || true
kubectl -n ingress-nginx wait --for=condition=complete --timeout=240s job/ingress-nginx-admission-patch || true
kubectl -n ingress-nginx rollout status --timeout=240s deployment/ingress-nginx-controller

helm dependency build --skip-refresh "${CHART_PATH}"
helm upgrade --install "${RELEASE_NAME}" "${CHART_PATH}" --namespace "${NAMESPACE}" --create-namespace

kubectl get all,cm,secret,ing -A | tee "${ROOT_DIR}/output.log"
