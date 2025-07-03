#!/bin/bash

# Створення кластера
kind create cluster --config cluster.yml

# Чекаємо, поки кластер готовий
sleep 20

# Деплой helm-чарту
helm dependency update helm-chart/todoapp

helm upgrade --install todoapp ./helm-chart/todoapp --namespace todoapp --create-namespace

# Вивід для output.log
kubectl get all,cm,secret,ing -A > output.log
