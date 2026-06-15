#!/bin/bash

kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
helm install todoapp ./helm-chart
helm dependency update .infrastructure/helm-chart/todoapp
helm install todoapp .infrastructure/helm-chart/todoapp -n todoapp
kubectl get all,cm,secret,ing -A > output.log

