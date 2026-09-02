# TodoApp Helm Deployment Instructions

## Prerequisites

Required tools:

* Docker
* kind
* kubectl
* Helm

Check versions:

```bash
docker --version
kind version
kubectl version --client
helm version
```

## Create Kubernetes Cluster

Create the kind cluster:

```bash
kind create cluster --name todoapp --config cluster.yml
```

Check nodes:

```bash
kubectl get nodes --show-labels
```

## MySQL Node Taints

Taint all MySQL nodes:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Verify:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## Helm Chart

The main chart is located at:

```text
.infrastructure/helm-chart/todoapp
```

Validate it:

```bash
helm lint .infrastructure/helm-chart/todoapp
```

Build the MySQL dependency:

```bash
helm dependency build .infrastructure/helm-chart/todoapp
```

The MySQL subchart is located at:

```text
.infrastructure/helm-chart/todoapp/charts/mysql
```

## Deploy TodoApp

Create the namespace:

```bash
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -
```

Install the chart:

```bash
helm upgrade --install todoapp .infrastructure/helm-chart/todoapp \
  --namespace todoapp
```

Check the release:

```bash
helm list -A
```

## Verify Deployment

Check all resources:

```bash
kubectl get all -n todoapp
```

Check storage:

```bash
kubectl get pv
kubectl get pvc -n todoapp
```

Check HPA:

```bash
kubectl get hpa -n todoapp
```

Check ServiceAccount and RBAC:

```bash
kubectl get serviceaccount,role,rolebinding -n todoapp
```

Check pod placement:

```bash
kubectl get pods -n todoapp -o wide
```

TodoApp pods should run on nodes labeled:

```text
app=todoapp
```

MySQL should run on nodes labeled:

```text
app=mysql
```

## Generate output.log

Run:

```bash
kubectl get all,cm,secret,ing -A > output.log
```

Check the file:

```bash
cat output.log
```

## Bootstrap

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run:

```bash
./bootstrap.sh
```

The script uses:

```text
.infrastructure/helm-chart/todoapp
```

## Final Validation

Run:

```bash
helm lint .infrastructure/helm-chart/todoapp
helm dependency build .infrastructure/helm-chart/todoapp
kubectl get nodes --show-labels
kubectl get all -n todoapp
kubectl get pv
kubectl get pvc -n todoapp
kubectl get hpa -n todoapp
cat output.log
```

## Git Submission

```bash
git status
git add .
git commit -m "Add Helm charts for TodoApp and MySQL"
git push origin helm-charts
```

Then create/update the Pull Request for validation.
