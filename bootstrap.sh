#!/bin/bash
set -e

kind create cluster --name todoapp --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm lint helm-chart/todoapp

helm dependency build helm-chart/todoapp

helm upgrade --install todoapp helm-chart/todoapp \
  --namespace todoapp

kubectl get all,cm,secret,ing -A > output.log