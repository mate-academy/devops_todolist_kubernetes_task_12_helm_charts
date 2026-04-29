#!/bin/bash

kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
helm dependency build .infrastructure/helm-chart/todoapp/
helm install release .infrastructure/helm-chart/todoapp/