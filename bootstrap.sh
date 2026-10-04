#!/usr/bin/env bash
set -euo pipefail

# Resolve paths relative to this script so it works from any current directory.
REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_PATH="$REPOSITORY_ROOT/.infrastructure/helm-chart/todoapp"

# MySQL Pods may use the dedicated workers only when they tolerate this taint.
kubectl taint nodes \
  --selector app=mysql \
  app=mysql:NoSchedule \
  --overwrite

# Ingress is a prerequisite for the Ingress object rendered by the chart. Do
# not reapply the remote installer on upgrades: its short-lived admission Jobs
# would otherwise be recreated on every bootstrap run.
if ! kubectl get deployment ingress-nginx-controller \
  --namespace ingress-nginx >/dev/null 2>&1; then
  kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
fi

# Ports 80/443 are mapped from the host to the ingress-ready control-plane Node.
kubectl patch deployment ingress-nginx-controller \
  --namespace ingress-nginx \
  --type merge \
  --patch '{"spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/os":"linux","ingress-ready":"true"}}}}}'

kubectl rollout status deployment/ingress-nginx-controller \
  --namespace ingress-nginx \
  --timeout=180s

# Wait until both the admission Service and its CA bundle are ready. This avoids
# a race where Helm creates the Ingress before the validating webhook can answer.
for attempt in {1..30}; do
  ADMISSION_ENDPOINT="$(kubectl get endpoints ingress-nginx-controller-admission \
    --namespace ingress-nginx \
    --output jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null || true)"
  ADMISSION_CA="$(kubectl get validatingwebhookconfiguration ingress-nginx-admission \
    --output jsonpath='{.webhooks[0].clientConfig.caBundle}' 2>/dev/null || true)"

  if [[ -n "$ADMISSION_ENDPOINT" && -n "$ADMISSION_CA" ]]; then
    break
  fi

  if [[ "$attempt" -eq 30 ]]; then
    echo "Ingress admission webhook did not become ready" >&2
    exit 1
  fi

  sleep 2
done

# The parent chart automatically renders its local mysql dependency.
helm upgrade --install todoapp "$CHART_PATH" \
  --namespace default \
  --wait \
  --timeout=10m

# Produce the artifact required by the task and GitHub Actions validator.
kubectl get all,cm,secret,ing -A > "$REPOSITORY_ROOT/output.log"
