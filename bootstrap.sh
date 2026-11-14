#!/bin/bash
set -e

# 1. Create the kind cluster
kind create cluster --config cluster.yml

# 2. Inspect nodes for labels and taints
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "^Name:|Taints:"

# 3. Taint the nodes labeled app=mysql
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# 4. Install the Ingress Controller and wait until it is ready
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# 5. Install metrics-server (required by the HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 6. Deploy the todoapp helm chart (the mysql sub-chart is deployed with it)
helm upgrade --install todoapp helm-chart/todoapp

# 7. Wait for the pods
kubectl wait --namespace mysql-mysql --for=condition=ready pod --selector=app=mysql --timeout=300s
kubectl wait --namespace todoapp-todoapp --for=condition=ready pod --selector=app=todoapp --timeout=300s

# 8. Save the state of the cluster
kubectl get all,cm,secret,ing -A > output.log
