#!/usr/bin/env bash
#
# bootstrap.sh - creates the kind cluster, installs the prerequisites
# (ingress-nginx, metrics-server) and deploys the todoapp Helm chart
# together with its mysql sub-chart.
#
# Usage:  bash bootstrap.sh
# Safe to re-run: each step checks the current state before acting.

set -euo pipefail

# ------------------------------------------------------------------ settings
CLUSTER_NAME="todoapp"
CLUSTER_CONFIG="cluster.yml"                    # relative to this script
CHART_DIR=".infrastructure/helm-chart/todoapp"  # relative to this script
RELEASE_NAME="todoapp-release"
RELEASE_NAMESPACE="default"                     # where Helm stores the release

# Namespaces are "<chart name>-<namespace from values.yaml>".
APP_NAMESPACE="todoapp-todoapp"
DB_NAMESPACE="mysql-mysql"

# "main" and "latest" work, but pinning (for example controller-v1.14.0 and
# v0.8.0) makes every run install the same versions.
INGRESS_NGINX_REF="controller-v1.15.1"
METRICS_SERVER_VERSION="v0.9.1"

# ------------------------------------------------------------------- helpers
log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

cd "$(dirname "${BASH_SOURCE[0]}")"

INGRESS_NGINX_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_REF}/deploy/static/provider/kind/deploy.yaml"
if [[ "$METRICS_SERVER_VERSION" == "latest" ]]; then
  METRICS_SERVER_URL="https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
else
  METRICS_SERVER_URL="https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
fi

# ------------------------------------------------------------------ preflight
log "Checking required tools and files"
for tool in docker kind kubectl helm; do
  command -v "$tool" >/dev/null 2>&1 || die "'$tool' is not installed or not in PATH"
done
[[ -f "$CLUSTER_CONFIG" ]] || die "cluster config '$CLUSTER_CONFIG' not found"
[[ -d "$CHART_DIR" ]] || die "chart directory '$CHART_DIR' not found"

# -------------------------------------------------------------------- cluster
log "Creating kind cluster '${CLUSTER_NAME}'"
if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "Cluster '${CLUSTER_NAME}' already exists, reusing it"
else
  kind create cluster --name "$CLUSTER_NAME" --config "$CLUSTER_CONFIG"
fi
kubectl config use-context "kind-${CLUSTER_NAME}"
kubectl wait --for=condition=Ready nodes --all --timeout=180s

log "Inspecting node labels"
kubectl get nodes --show-labels

log "Tainting nodes labeled app=mysql with app=mysql:NoSchedule"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
kubectl describe nodes | grep -E "^Name:|Taints:"

# -------------------------------------------------------------- ingress-nginx
log "Installing ingress-nginx (${INGRESS_NGINX_REF})"
kubectl apply -f "$INGRESS_NGINX_URL"

# cluster.yml maps host ports 80 and 443 to the control-plane node only, so
# the controller has to run on that node (it is labeled ingress-ready=true
# and tainted, hence the toleration).
kubectl patch deployment ingress-nginx-controller -n ingress-nginx \
  --type=merge \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}}}'
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=240s

# ------------------------------------------------------------- metrics-server
log "Installing metrics-server (${METRICS_SERVER_VERSION})"
kubectl apply -f "$METRICS_SERVER_URL"

# kind nodes use self-signed kubelet certificates, so metrics-server needs
# --kubelet-insecure-tls. The check keeps re-runs from adding it twice.
if ! kubectl get deployment metrics-server -n kube-system \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl patch deployment metrics-server -n kube-system --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=180s

# ----------------------------------------------------------------- helm chart
log "Linting the chart"
helm lint "$CHART_DIR"

# The chart creates its own namespaces, so --create-namespace is not used.
log "Deploying ${RELEASE_NAME}"
helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" \
  --namespace "$RELEASE_NAMESPACE" \
  --wait --timeout 10m

log "Waiting for the workloads"
kubectl rollout status statefulset/mysql -n "$DB_NAMESPACE" --timeout=300s
kubectl rollout status deployment/todoapp -n "$APP_NAMESPACE" --timeout=300s

# The HPA shows <unknown> until metrics-server has scraped the pods once.
log "Waiting for the HPA to receive CPU and memory metrics"
hpa_ready="false"
for _ in $(seq 1 36); do
  metrics="$(kubectl get hpa todoapp -n "$APP_NAMESPACE" \
    -o jsonpath='{.status.currentMetrics[*].resource.name}' 2>/dev/null || true)"
  if [[ "$metrics" == *cpu* && "$metrics" == *memory* ]]; then
    hpa_ready="true"
    break
  fi
  sleep 5
done
if [[ "$hpa_ready" != "true" ]]; then
  echo "WARNING: the HPA has no metrics yet; check again in a minute" >&2
fi

# -------------------------------------------------------------------- summary
log "Deployment finished"
kubectl get pods -A
kubectl get hpa -n "$APP_NAMESPACE"
kubectl get pv,pvc -A

cat <<EOF

The app is available at http://localhost/ (through the ingress) or with:
  kubectl port-forward -n ${APP_NAMESPACE} svc/todoapp-service 8080:80
EOF