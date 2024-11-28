#!/bin/bash

# Stop the script if any command fails
set -e

# Step 1: Fork the repository (Assuming it's already done on GitHub manually)

# Step 2: Set up the kind cluster using the cluster.yml configuration file
echo "Spinning up the kind cluster..."
kind create cluster --config cluster.yml

# Step 3: Inspect Nodes for Labels and Taints
echo "Inspecting nodes for labels and taints..."
kubectl get nodes --show-labels
kubectl get nodes -o json | jq '.items[].spec.taints'

# Step 4: Taint nodes labeled with app=mysql
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath="{.items[0].metadata.name}")
kubectl taint nodes $MYSQL_NODE app=mysql:NoSchedule --overwrite
echo "Node $MYSQL_NODE tainted with app=mysql:NoSchedule"

# Step 5: Create a Helm chart named 'todoapp' inside a 'helm-chart' directory
echo "Creating Helm chart..."
mkdir -p helm-chart
helm create helm-chart/todoapp

# Step 6: Add MySQL as a sub-chart under 'charts' directory
echo "Creating MySQL sub-chart..."
helm create helm-chart/todoapp/charts/mysql

# Step 7: Add MySQL as a dependency in todoapp Chart.yaml
echo "Adding MySQL dependency to todoapp Chart.yaml..."
cat <<EOF >> helm-chart/todoapp/Chart.yaml
dependencies:
- name: mysql
  version: "0.1.0"
  repository: "file://./charts/mysql"
EOF

# Step 8: Install the Helm chart for todoapp
echo "Installing todoapp Helm chart..."
helm install todoapp ./helm-chart/todoapp --namespace todoapp-namespace --create-namespace

# Step 9: Get all resources and save the output in output.log
echo "Saving Kubernetes resources to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "Bootstrap completed successfully!"
