#!/bin/bash
set -e
kind create cluster --config cluster.yml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
helm install todoapp .infrastructure/helm-chart/todoapp
helm dependency update .infrastructure/helm-chart/todoapp
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp
