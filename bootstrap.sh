#!/bin/bash

echo
kind create cluster --config cluster.yml

echo
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

echo
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

sleep 15

echo
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp --namespace todoapp --create-namespace

echo
kubectl apply -f .infrastructure/ingress/ingress.yml

echo
kubectl get all,cm,secret,ing -A > output.log

echo