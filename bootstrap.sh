#!/usr/bin/env bash
set -euo pipefail

# 1) кластер kind
if ! kind get clusters | grep -q "^todo$"; then
  kind create cluster --config ./cluster.yml --name todo
fi
kubectl config use-context kind-todo

# 2) (опційно) лейбли/тейнти для завдання з плануванням
kubectl label nodes kind-worker app=mysql --overwrite || true
kubectl label nodes kind-worker2 app=mysql --overwrite || true
kubectl taint  nodes -l app=mysql app=mysql:NoSchedule --overwrite || true
kubectl label nodes kind-control-plane app=todoapp --overwrite || true

# 3) оновити залежності та задеплоїти Helm-чарт
helm dependency update helm-chart/todoapp
helm upgrade --install todo helm-chart/todoapp \
  --namespace "$(yq '.namespace' helm-chart/todoapp/values.yaml)" \
  --create-namespace

# 4) зняти зліпок стану
kubectl get all,cm,secret,ing -A | tee output.log

echo "Done. Open output.log and verify."
