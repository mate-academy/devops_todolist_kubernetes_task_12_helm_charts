#!/usr/bin/env bash
set -euo pipefail

if ! kind get clusters | grep -qx kind; then
	kind create cluster --config cluster.yml
fi

kubectl get nodes -l app=mysql -o name | while read -r node; do
	kubectl taint nodes "${node#node/}" app=mysql:NoSchedule --overwrite
done

docker build -t todoapp:latest src
kind load docker-image todoapp:latest

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s
if [[ "$(kubectl get pv todoapp-pv -o jsonpath='{.status.phase}' 2>/dev/null || true)" == "Released" ]]; then
	kubectl delete pv todoapp-pv
fi
helm dependency build helm-chart/todoapp
helm upgrade --install todoapp helm-chart/todoapp \
	--namespace todoapp \
	--create-namespace \
	--wait

kubectl get all,cm,secret,ing -A > output.log
