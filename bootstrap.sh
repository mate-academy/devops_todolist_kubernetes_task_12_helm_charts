#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="kind"
RELEASE_NAME="kube2py-release"
CHART_PATH=".infrastructure/helm-chart/todoapp"

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --config cluster.yml
fi

kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'

kubectl label nodes "${CLUSTER_NAME}-worker" "${CLUSTER_NAME}-worker2" app=mysql --overwrite
kubectl label nodes "${CLUSTER_NAME}-worker3" "${CLUSTER_NAME}-worker4" app=kube2py --overwrite
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm dependency update "${CHART_PATH}"
helm upgrade --install "${RELEASE_NAME}" "${CHART_PATH}" --wait --timeout 5m

kubectl get all,cm,secret,ing -A | tee output.log
