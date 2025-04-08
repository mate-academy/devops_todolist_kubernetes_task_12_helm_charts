#!/bin/bash
kind create cluster --config cluster.yml # create work cluster on the configuration file cluster.yml.
sleep 5
kubectl taint nodes -l app=mysql app=mysql:NoSchedule # Applies a taint (a restriction) to all nodes with the label app=mysql
helm install todoapp .infrastructure/helm-chart/todoapp # Installs a Helm chart named todoapp from the local directory helm-chart/todoapp.
# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
kubectl get all,cm,secret,ing -A > output.log # Fetches information about all resources across all namespaces (-A) and saves it to a file named output.log.