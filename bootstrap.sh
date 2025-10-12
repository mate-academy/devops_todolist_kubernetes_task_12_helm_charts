#!/bin/bash
kind delete cluster
kind create cluster --config cluster.yml

# Taint nodes labeled app=mysql
kubectl taint nodes -l app=mysql app=mysql:NoSchedule || true

# Install Helm chart
helm install todoapp helm-chart/todoapp

# Save output to output.log at repo root
kubectl get all,cm,secret,ing -A > output.log
