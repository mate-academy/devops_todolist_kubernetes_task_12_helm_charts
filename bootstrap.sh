#!/bin/bash
set -euo pipefail

CLUSTER="todo"
CHART_DIR="helm-chart/todoapp"
RELEASE="todoapp"

if ! kind get clusters | grep -qx "$CLUSTER"; then
  kind create cluster --config cluster.yml --name "$CLUSTER"
fi
kubectl config use-context "kind-$CLUSTER"

CONTEXT="$(kubectl config current-context)"
if [[ "$CONTEXT" != kind-* ]]; then
  echo "Refusing to run: current kubectl context is '$CONTEXT', expected a kind-* context" >&2
  exit 1
fi

kubectl get nodes --show-labels
kubectl describe nodes | grep -E '^(Name|Taints):'
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
kubectl describe nodes | grep -E '^(Name|Taints):'

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl get deployment metrics-server -n kube-system \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl patch deployment metrics-server -n kube-system --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl rollout status deployment/metrics-server -n kube-system --timeout=300s

helm dependency update "$CHART_DIR"
helm upgrade --install "$RELEASE" "$CHART_DIR" -f "$CHART_DIR/values.yaml" --wait --timeout 10m

kubectl get all,cm,secret,ing -A | tee output.log
