#!/bin/bash
set -e

CLUSTER=todoapp

# Prerequisites: kind cluster from cluster.yml
#kind delete cluster --name "$CLUSTER" || true
kind create cluster --name "$CLUSTER" --config cluster.yml

# Taint nodes labeled app=mysql (from cluster.yml) so only mysql workloads land there
for node in $(kubectl get nodes -l app=mysql -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}'); do
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite
done

# Deploy the helm chart (mysql subchart comes along via the Chart.yaml dependency)
helm install todoapp .infrastructure/helm-chart/todoapp
