#!/bin/bash
kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm dependency update .infrastructure/helm-chart/todoapp

helm upgrade --install todoapp .infrastructure/helm-chart/todoapp --namespace todoapp --create-namespace