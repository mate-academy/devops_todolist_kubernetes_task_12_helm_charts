#!/bin/bash

# 1. Створення кластера Kind
kind delete cluster --name my-cluster
kind create cluster --config cluster.yml --name my-cluster

# Очікування готовності вузлів
echo "Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Отримуємо імена робочих вузлів (припускаємо, що вони називаються my-cluster-worker та my-cluster-worker2)
WORKER_NODES=$(kubectl get nodes -o custom-columns=NAME:.metadata.name --no-headers | grep worker)
WORKER_NODE_1=$(echo "$WORKER_NODES" | awk 'NR==1 {print $1}')
WORKER_NODE_2=$(echo "$WORKER_NODES" | awk 'NR==2 {print $1}')

# 2. Інспекція, Мічення та Позначення Вузлів (Вимога 3, 4)

# Вузол 1: Для MySQL (для Toleration)
echo "▶️ Labeling node ${WORKER_NODE_1} for MySQL: app=mysql"
kubectl label node ${WORKER_NODE_1} app=mysql --overwrite=true

echo "▶️ Tainting node ${WORKER_NODE_1} with app=mysql:NoSchedule"
kubectl taint node ${WORKER_NODE_1} app=mysql:NoSchedule --overwrite=true

# Вузол 2: Для TodoApp (для Node Affinity)
echo "▶️ Labeling node ${WORKER_NODE_2} for TodoApp: app=kube2py"
kubectl label node ${WORKER_NODE_2} app=kube2py --overwrite=true

# 3. Розгортання Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

# 4. Оновлення залежностей Helm (важливо для підчартів)
echo "▶️ Updating Helm chart dependencies..."
helm dependency update .infrastructure/helm-chart/todoapp

# 5. Розгортання Helm-чарту
echo "▶️ Deploying Helm chart: todoapp"
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp

# 6. Збір виводу
echo "▶️ Deployment complete. Getting status and writing to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "✅ Deployment finished. Check output.log"