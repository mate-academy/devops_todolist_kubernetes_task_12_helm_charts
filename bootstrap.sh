#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="kind"
CHART_PATH="./.infrastructure/helm-chart/todoapp"

# 1. Start the cluster if it doesn't exist
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Creating cluster..."
  kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml
fi

# 2. Build chart dependencies
echo "Building chart dependencies..."
helm dependency build "${CHART_PATH}"

# 3. Install the application
echo "Installing TodoApp..."
helm upgrade --install todoapp "${CHART_PATH}" --create-namespace -n todoapp

# 4. Wait for the deployment
echo "Waiting for TodoApp to be ready..."
kubectl rollout status deployment -n todoapp -l app=todoapp --timeout=60s

# 5. Wait for the pod to be ready
echo "Waiting for TodoApp pods to be ready..."
kubectl wait --for=condition=Ready pod -l app=todoapp -n todoapp --timeout=60s

# 6. Run migrations
echo "Running migrations..."
for i in {1..5}; do
  POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath="{.items[0].metadata.name}" 2>/dev/null || echo "")
  
  if [ -n "$POD_NAME" ]; then
    echo "Found pod: $POD_NAME, running migrations..."
    if kubectl exec "$POD_NAME" -n todoapp -- python manage.py migrate; then
      echo "Migrations completed successfully!"
      break
    else
      echo "Migration failed, retrying in 5s..."
    fi
  fi
  sleep 5
done

echo "TodoApp is up and running!"