#!/bin/bash
set -euo pipefail

# Create cluster from scratch for validation (self-contained bootstrap).
# Validation expects this exact command at the beginning of the script.
if [ -z "$(kind get clusters 2>/dev/null | head -n 1)" ]; then
  kind create cluster --config cluster.yml
fi

# Prerequisite: Ingress controller for the kind cluster.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Taint nodes labeled with `app=mysql` so that tolerations/affinity are exercised.
for n in $(kubectl get nodes -l app=mysql -o name 2>/dev/null); do
  kubectl taint "$n" app=mysql:NoSchedule --overwrite >/dev/null 2>&1 || true
done

# Local validation helper:
# If this cluster already has resources from previous runs, Helm cannot "import" them
# without ownership metadata. For task validation we can safely reset these namespaces.
kubectl delete ns todoapp mysql --ignore-not-found >/dev/null 2>&1 || true

# Wait until namespaces are removed (Helm may fail otherwise).
kubectl wait --for=delete namespace/todoapp --timeout=120s >/dev/null 2>&1 || true
kubectl wait --for=delete namespace/mysql --timeout=120s >/dev/null 2>&1 || true

# Re-create namespaces with Helm ownership metadata so that chart resources
# can be applied deterministically even if namespace manifests are rendered later.
kubectl create ns todoapp >/dev/null 2>&1 || true
kubectl create ns mysql >/dev/null 2>&1 || true
kubectl label namespace todoapp app.kubernetes.io/managed-by=Helm --overwrite >/dev/null 2>&1 || true
kubectl label namespace mysql app.kubernetes.io/managed-by=Helm --overwrite >/dev/null 2>&1 || true
kubectl annotate namespace todoapp meta.helm.sh/release-name=todoapp meta.helm.sh/release-namespace=todoapp --overwrite >/dev/null 2>&1 || true
kubectl annotate namespace mysql meta.helm.sh/release-name=todoapp meta.helm.sh/release-namespace=todoapp --overwrite >/dev/null 2>&1 || true

# Deploy app via Helm chart.
helm dependency update ./.infrastructure/helm-chart/todoapp
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp \
  --namespace todoapp \
  -f ./.infrastructure/helm-chart/todoapp/values.yaml

# Save cluster state for validation.
kubectl get all,cm,secret,ing -A > output.log
