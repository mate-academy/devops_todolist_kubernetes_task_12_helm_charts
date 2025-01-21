#!/bin/bash
# Create a Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r src/requirements.txt

# Create a cluster using kind
kind create cluster --config cluster.yml

# Set up the Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Taint nodes with app=mysql label to prevent scheduling
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Update Helm chart dependencies
helm dependency update ./helm-chart/todoapp

# Install the todoapp Helm chart
helm install todoapp helm-chart/todoapp

# Gather resources info and write it to output.log
kubectl get all,cm,secret,ing -A > output.log