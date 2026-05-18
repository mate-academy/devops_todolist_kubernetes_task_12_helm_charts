#!/bin/bash
kind delete cluster --name kind
kind create cluster --config ./cluster.yml
kubectl get nodes --show-labels
kubectl taint nodes <node-name> app=mysql:NoSchedule
helm dependency build .infrastructure/helm-chart/todoapp
helm install todoapp .infrastructure/helm-chart/todoapp/
kubectl get all,cm,secret,ing -A > output.log