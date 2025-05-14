#!/bin/bash
kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm install todoapp .infrastructure/helm-chart/todoapp