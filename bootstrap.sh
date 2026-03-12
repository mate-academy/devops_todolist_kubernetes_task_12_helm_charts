#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-todoapp}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${ROOT_DIR}/.infrastructure/helm-chart/todoapp"

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/cluster.yml"
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null

echo "Inspecting node labels before taints"
kubectl get nodes -L app
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

echo "Applying mysql taints"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "Inspecting node taints after update"
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

echo "Installing ingress-nginx for kind"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s

echo "Installing metrics-server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- "--kubelet-insecure-tls"; then
  kubectl patch deployment metrics-server -n kube-system --type json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl rollout status deployment/metrics-server -n kube-system --timeout=300s

echo "Building chart dependencies"
helm dependency build "${CHART_DIR}"

echo "Deploying todoapp chart"
helm upgrade --install todoapp "${CHART_DIR}" --namespace todoapp --create-namespace --wait --timeout 600s

kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
kubectl rollout status statefulset/mysql -n mysql --timeout=300s

kubectl get all,cm,secret,ing -A > "${ROOT_DIR}/output.log"
