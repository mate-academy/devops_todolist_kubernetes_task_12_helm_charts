#!/bin/bash

set -e

echo "🚀 Starting deployment of ToDo application with Helm charts..."

# Create kind cluster if it doesn't exist
echo "📦 Creating kind cluster..."
kind create cluster --config cluster.yml || echo "Cluster already exists or creation failed"

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Inspect nodes and their labels
echo "🔍 Inspecting nodes for labels and taints..."
kubectl get nodes --show-labels

# Add taints to nodes labeled with app=mysql
echo "🏷️  Adding taints to MySQL nodes..."
for node in $(kubectl get nodes -l app=mysql --no-headers -o custom-columns=NAME:.metadata.name); do
    echo "Adding taint to node: $node"
    kubectl taint node $node app=mysql:NoSchedule --overwrite=true || echo "Taint already exists on $node"
done

# Install metrics server for HPA
echo "📊 Installing metrics server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch metrics server for kind
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  },
  {
    "op": "add", 
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-preferred-address-types=InternalIP"
  }
]'

# Install Ingress Controller
echo "🌐 Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Update Helm dependencies
echo "📦 Updating Helm dependencies..."
cd helm-chart/todoapp
helm dependency update
cd ../..

# Deploy the todoapp helm chart
echo "🚀 Deploying todoapp Helm chart..."
helm upgrade --install todoapp helm-chart/todoapp \
  --create-namespace \
  --wait \
  --timeout=600s

echo "✅ Deployment completed successfully!"

# Show deployment status
echo "📊 Current deployment status:"
kubectl get all,cm,secret,ing -A

# Save deployment status to output.log as required by the task
echo "💾 Saving deployment status to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "✅ Deployment status saved to output.log"
echo "🎉 ToDo application deployed successfully!"
echo "📝 Access the application through the ingress or port-forward to the service."
