#!/bin/bash

kind delete cluster
kind create cluster --config cluster.yaml

kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule

helm install todoapp helm-chart/todoapp/
helm get all todoapp
