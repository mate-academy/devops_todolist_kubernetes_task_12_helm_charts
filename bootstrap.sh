#!/usr/bin/env bash
set -euo pipefail

# Recreate kind cluster from config
kind delete cluster || true
kind create cluster --config cluster.yml

# Inspect nodes for labels & taints
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Taint nodes labeled with app=mysql
kubectl taint nodes -l app=mysql app=mysql:NoSchedule || true

# Explicitly update chart dependencies (mysql subchart)
helm dependency update helm-chart/todoapp

# Install / upgrade the chart
helm upgrade --install todoapp helm-chart/todoapp

# Save cluster objects overview
kubectl get all,cm,secret,ing -A > output.log
