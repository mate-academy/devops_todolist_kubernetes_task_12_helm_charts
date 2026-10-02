#!/bin/bash

kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.3/deploy/static/provider/kind/deploy.yaml

kubectl patch deployment ingress-nginx-controller \
  -n ingress-nginx \
  --type merge \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/os":"linux","ingress-ready":"true"}}}}}'

kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

cd .infrastructure/helm-chart/todoapp

helm dependency update .

helm install todoapp .

kubectl get all,cm,secret,ing -A > ../../../output.log