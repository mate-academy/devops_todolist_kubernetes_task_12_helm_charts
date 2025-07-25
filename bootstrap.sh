#!/bin/bash

kind delete cluster
kind create cluster --config cluster.yml

kubectl taint nodes kind-worker app=mysql:NoSchedule
kubectl taint nodes kind-worker2 app=mysql:NoSchedule

helm install todoapp helm-chart/todoapp/
helm get all todoapp
