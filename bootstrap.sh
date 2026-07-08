#!/bin/bash
set -e

echo "== Creating kind cluster =="
kind create cluster --config cluster.yml --name todoapp-cluster

echo "== Waiting for nodes to be ready =="
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "== Tainting mysql-labeled nodes =="
for node in $(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}'); do
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite
done

echo "== Installing NGINX Ingress Controller =="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "== Waiting for Ingress Controller to be ready =="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "== Updating Helm dependencies =="
helm dependency update helm-chart/todoapp

echo "== Installing todoapp Helm chart =="
helm install todoapp helm-chart/todoapp --namespace todoapp --create-namespace

echo "== Done. Checking pods =="
kubectl get pods -n todoapp
kubectl get pods -n mysql