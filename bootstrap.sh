#!/bin/bash

set -e

kind create cluster --name todoapp --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -

helm lint .infrastructure/helm-chart/todoapp

helm dependency build .infrastructure/helm-chart/todoapp

helm upgrade --install todoapp .infrastructure/helm-chart/todoapp \
  --namespace todoapp

kubectl get all,cm,secret,ing -A > output.log

