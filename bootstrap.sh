#!/bin/bash
kind delete cluster
kind create cluster --config cluster.yml

kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule

helm install todoapp .infrastructure/helm-charts/todoapp/
helm get all todoapp