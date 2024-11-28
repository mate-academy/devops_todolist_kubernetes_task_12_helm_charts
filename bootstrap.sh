#!/bin/bash
kind create cluster --config ./cluster.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
helm install todoapp ./.infrastructure/helm-chart/todoapp/

