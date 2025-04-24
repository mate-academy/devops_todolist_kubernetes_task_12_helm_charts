#!/bin/bash
kind create cluster --config cluster.yml

kubectl taint nodes kind-worker app=mysql:NoSchedule
kubectl taint nodes kind-worker2 app=mysql:NoSchedule

helm install todoapp-test .infrastructure/helm-chart/todoapp
# Install Ingress Controller
# kubectl apply -f .infrastructure/ingress/ingress.yml

