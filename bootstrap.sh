#!/bin/bash
kind create cluster --config ./cluster.yml
kubectl kubectl get nodes --show-labels
kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule
helm dependency update ./todoapp
helm install todoapp ./todoapp
kubectl get all,cm,secret,ing -A > output.log
