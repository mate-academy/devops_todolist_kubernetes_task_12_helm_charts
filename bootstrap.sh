#!/bin/bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-kind}"
CHART_DIR=".infrastructure/helm-chart/todoapp"

# 1. Create kind cluster from cluster.yml (skip if it already exists)
if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  kind create cluster --name "$CLUSTER_NAME" --config cluster.yml
fi

# 2. Inspect nodes labels and taints
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# 3. Taint nodes labeled app=mysql
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# 4. Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# 5. Deploy todoapp helm chart (with mysql sub-chart)
helm upgrade --install todoapp "$CHART_DIR" -f "$CHART_DIR/values.yaml" --wait --timeout 10m

# 6. Save cluster state
kubectl get all,cm,secret,ing -A > output.log
