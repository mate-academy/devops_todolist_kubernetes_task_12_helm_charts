#!/bin/bash
set -e
kind create cluster --config cluster.yaml
kubectl get nodes -l app=mysql -o name | xargs -I {} kubectl taint {} app=mysql:NoSchedule
helm install todoapp-release .infrastructure/helm-chart/todoapp

kubectl get all,cm,secret,ing -A > output.log
