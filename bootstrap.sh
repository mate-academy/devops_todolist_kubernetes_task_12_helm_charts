#!/bin/bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r src/requirements.txt

kind create cluster --config cluster.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm dependency update ./helm-chart/todoapp
helm install todoapp helm-chart/todoapp