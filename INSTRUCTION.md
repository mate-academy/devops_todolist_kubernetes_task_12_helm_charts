# Validation Guide

## Prerequisites

- Docker + kind
- kubectl
- Helm v3

## 1) Create kind cluster

    kind create cluster --config cluster.yml

## 2) Inspect nodes for labels and taints

    kubectl get nodes --show-labels
    kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

Якщо потрібно, додайте лейбл на конкретний вузол:
kubectl label nodes <node-name> app=mysql="true" --overwrite

## 3) Taint nodes labeled app=mysql

    kubectl taint nodes -l app=mysql app=mysql:NoSchedule

## 4) Deploy the Helm chart (with explicit deps update)

    helm dependency update helm-chart/todoapp
    helm upgrade --install todoapp helm-chart/todoapp

Примітка: Namespace’и створюються чартом: `todoapp` і `mysql` (через шаблони `ns.yml`).

## 5) Accessing the app

### Option A: NodePort (default)

Values set:

- todoapp.service.type=NodePort
- todoapp.service.port=80
- todoapp.service.nodePort=30007
- todoapp.ports.container=8080

Get the kind node IP (usually 127.0.0.1 with port-forwarding via kind):
kubectl get svc -n todoapp

Test:
curl -i http://localhost:30007/api/health

### Option B: ClusterIP + Ingress (optional)

Set in helm-chart/todoapp/values.yaml:
todoapp:
service:
type: ClusterIP
port: 80

Install ingress-nginx for kind:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller

Ingress is todoapp-ingress in namespace todoapp. Test (controller is usually on NodePort inside kind):
kubectl -n ingress-nginx get svc # Replace <INGRESS_NODEPORT_HTTP> with the 'http' NodePort from the output
curl -i http://localhost:<INGRESS_NODEPORT_HTTP>/

## 6) Check resources

    kubectl get all -n todoapp
    kubectl get all -n mysql
    kubectl get cm,secret -n todoapp
    kubectl get cm,secret -n mysql

## 7) Validate requirements

- Namespaces: controlled via values.yaml (.Values.common.namespace) in both charts.
- Name prefix: all resource metadata.name use {{ .Chart.Name }}-… (except ServiceAccount which is controlled from values as required).
- Secrets: controlled from values.yaml, encoded via range in secret.yml; in Deployment env variables mapped via range.
- Resources & RollingUpdate: controlled from values.yaml.
- Image repo & tag: controlled from values.yaml.
- Node Affinity: controlled from values.yaml (todoapp: key/values).
- HPA: min/max and avg CPU/Memory from values.yaml.
- PV/PVC: capacities from values.yaml.
- Service Account in Deployment and RBAC: name comes from values.yaml.
- Sub-chart mysql: placed in charts/mysql, names prefixed by .Chart.Name, secrets via range, replicas/image/resources/pvc/affinity/tolerations from its values.yaml.
- Dependencies: Chart.yaml includes dependencies, and helm dependency update run before install.
- Output log: run:
  kubectl get all,cm,secret,ing -A > output.log

## 8) Cleanup

    kind delete cluster
