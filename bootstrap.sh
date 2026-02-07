#!/bin/bash
set -e

CLUSTER_NAME="kind"

echo "1. Creating Cluster..."
if ! kind get clusters | grep -q "^$CLUSTER_NAME$"; then
  kind create cluster --config cluster.yml
else
  echo "Cluster already exists."
fi

echo "2. Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "3. Tainting MySQL nodes..."
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}')

if [ -n "$MYSQL_NODE" ]; then
    echo "Found node for MySQL: $MYSQL_NODE"
    if ! kubectl describe node $MYSQL_NODE | grep -q "app=mysql:NoSchedule"; then
        kubectl taint nodes $MYSQL_NODE app=mysql:NoSchedule
        echo "Node tainted."
    else
        echo "Node already tainted."
    fi
else
    echo "WARNING: No node with label app=mysql found!"
fi

echo "4. Installing Helm Chart..."
kubectl create namespace todo-ns --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install todoapp ./helm-chart/todoapp --namespace todo-ns

echo "5. Waiting for pods..."
kubectl wait --namespace todo-ns \
  --for=condition=ready pod \
  --selector=app=todoapp \
  --timeout=180s

echo "6. Generating output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "Deployment finished successfully!"