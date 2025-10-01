#!/bin/bash
set -e

# Create kind cluster
kind create cluster --config cluster.yml

kubectl apply -f .infrastructure/security/ns.yml

helm dependency update ./helm-chart/todoapp
helm upgrade --install todoapp ./helm-chart/todoapp -n todoapp --create-namespace

kubectl get pods -n todoapp

kubectl get all,cm,secret,ing -A > output.log