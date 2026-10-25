#!/bin/bash
set -e

# 1. Кластер
kind create cluster --config cluster.yml

# 2. Ingress NGINX
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# 3. Metrics Server (нужен для HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 4. Taint для mysql-нод
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# 5. Деплой чарта
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp --wait --timeout 10m

# 6. Сохранение вывода
kubectl get all,cm,secret,ing -A > output.log
