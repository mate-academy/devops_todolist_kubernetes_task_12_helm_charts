#!/bin/bash

set -e

NAMESPACE="todoapp"

echo "Creating namespace (if not exists)..."
kubectl create namespace $NAMESPACE || echo "Namespace $NAMESPACE already exists."

echo "Deploying Helm chart..."
helm upgrade --install todoapp ./helm-chart/todoapp -n $NAMESPACE

echo "Waiting for pods to be ready..."
kubectl wait --namespace $NAMESPACE --for=condition=Ready pod --all --timeout=180s

echo "Exporting Kubernetes resources to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "Done! Resources saved in output.log"


# #!/bin/bash
# kubectl apply -f .infrastructure/mysql/ns.yml
# kubectl apply -f .infrastructure/mysql/configMap.yml
# kubectl apply -f .infrastructure/mysql/secret.yml
# kubectl apply -f .infrastructure/mysql/service.yml
# kubectl apply -f .infrastructure/mysql/statefulSet.yml

# kubectl apply -f .infrastructure/app/ns.yml
# kubectl apply -f .infrastructure/app/pv.yml
# kubectl apply -f .infrastructure/app/pvc.yml
# kubectl apply -f .infrastructure/app/secret.yml
# kubectl apply -f .infrastructure/app/configMap.yml
# kubectl apply -f .infrastructure/app/clusterIp.yml
# kubectl apply -f .infrastructure/app/nodeport.yml
# kubectl apply -f .infrastructure/app/hpa.yml
# kubectl apply -f .infrastructure/app/deployment.yml

# # Install Ingress Controller
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# # kubectl apply -f .infrastructure/ingress/ingress.yml
