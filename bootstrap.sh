#!/bin/bash

# create cluster
kind create cluster --config cluster.yml

# Taint nodes labeled with `app=mysql` with `app=mysql:NoSchedule`
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Start project
helm install todoapp-release .infrastructure/helm-chart/todoapp/

