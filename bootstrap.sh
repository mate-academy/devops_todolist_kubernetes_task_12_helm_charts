#!/bin/bash

# Створення Kind кластера
kind create cluster --config cluster.yml

# Для тейнту спочатку треба підписати (помітити) ноду лейблом, потім застосувати тейнт
kubectl label node <node-name> app=mysql
kubectl taint nodes <node-name> app=mysql:NoSchedule

# Встановлення todoapp з dependency mysql через Helm
helm dependency update ./helm-charts/todoapp
helm upgrade --install todoapp ./helm-charts/todoapp -n todoapp --create-namespace

# Встановлення Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
