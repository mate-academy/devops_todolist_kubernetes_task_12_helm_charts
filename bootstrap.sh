#!/bin/bash
set -euo pipefail

helm dependency build ./helm-chart/todoapp

kubectl get nodes --show-labels
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

# Install the kind ingress controller on the node mapped to host port 80.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx patch deployment ingress-nginx-controller --type='strategic' -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"}}}}}'
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=180s

helm upgrade --install todoapp ./helm-chart/todoapp --namespace todoapp --create-namespace --wait --timeout 10m

kubectl get all,cm,secret,ing -A > output.log
echo "Application is available at http://localhost/"
