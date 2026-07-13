#!/bin/bash
set -e

kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl patch deployment -n ingress-nginx ingress-nginx-controller --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/nodeSelector/ingress-ready","value":"true"}]'

# kubectl apply -f .infrastructure/ingress/ingress.yml


kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Deploy helm chart
helm dependency update .infrastructure/helm-chart/todoapp

helm install todoapp .infrastructure/helm-chart/todoapp -f .infrastructure/helm-chart/todoapp/values.yaml

kubectl wait --namespace mysql \
  --for=condition=ready pod \
  --selector=app=mysql \
  --timeout=180s

kubectl apply -f pod.yml

# Save output

sleep 180
kubectl get all,cm,secret,ing -A > output.log