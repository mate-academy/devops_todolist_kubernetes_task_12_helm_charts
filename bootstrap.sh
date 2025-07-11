#!/bin/bash

# Stop on any error
set -e

echo "Deleting existing Kind cluster if it exists..."
kind delete cluster || true

echo "Creating Kind cluster with cluster.yml..."
kind create cluster --config cluster.yml

echo "Waiting for control-plane node to be ready..."
kubectl wait node kind-control-plane --for=condition=Ready --timeout=300s

echo "Inspecting nodes for labels and taints..."
kubectl get nodes --show-labels

# Find the node labeled app=mysql and taint it
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}')

if [ -z "$MYSQL_NODE" ]; then
  echo "Error: Node with label app=mysql not found. Please ensure your cluster.yml configures it."
  exit 1
fi

echo "Tainting node '$MYSQL_NODE' with app=mysql:NoSchedule..."
kubectl taint node "$MYSQL_NODE" app=mysql:NoSchedule --overwrite

echo "Verifying taint on node '$MYSQL_NODE'..."
kubectl describe node "$MYSQL_NODE" | grep Taints

echo "Installing Ingress NGINX Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress NGINX Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "Building Docker image for the Django ToDo app..."
docker build -t leoleiden/django-todo-app:latest .

echo "Loading Docker image into Kind cluster..."
kind load docker-image leoleiden/django-todo-app:latest

echo "Deploying todoapp Helm chart..."
helm upgrade --install todoapp helm-chart/todoapp -f helm-chart/todoapp/values.yaml

echo "Waiting for todoapp deployment to be ready..."
kubectl rollout status deployment/todoapp-todoapp-deployment -n todoapp-prod --timeout=300s

echo "Waiting for mysql statefulset to be ready..."
kubectl rollout status statefulset/mysql-mysql -n mysql-prod --timeout=300s

echo "Collecting kubectl output to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "Deployment complete. Check output.log for details."
echo "You can now validate the application by following instructions in INSTRUCTION.md."