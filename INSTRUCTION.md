# INSTRUCTION.md

## Overview

This document describes how to validate the Kubernetes and Helm-based ToDo application deployment in a **kind** cluster.

---

## 1. Prerequisites

Ensure you have the following installed:

* `git`
* `kubectl`
* `kind`
* `helm`

---

## 2. Clone Repository

```bash
git clone https://github.com/OlehHavelia1994/devops_todolist_kubernetes_task_12_helm_charts.git
```

---

## 3. Create Kubernetes Cluster (kind)

```bash
kind create cluster --config cluster.yml
```

Verify cluster:

```bash
kubectl get nodes
```

---

## 4. Inspect Nodes for Labels and Taints

Check labels:

```bash
kubectl get nodes --show-labels
```

---

## 5. Apply Required Taints

Find nodes with label:

```bash
kubectl get nodes --show-labels | grep app=mysql
```

Apply taint:

```bash
kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule
```

Verify:

```bash
kubectl describe node kind-worker kind-worker2 | grep Taints
```

---

## 6. Deploy Application Using bootstrap.sh

Run:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This script should:

* Install dependencies
* Deploy Helm chart (`todoapp`)
* Deploy sub-chart (`mysql`)

---

## 7. Validate Helm Deployment

Check Helm releases:

```bash
helm list -A
```

---

## 8. Validate Kubernetes Resources

Run:

```bash
kubectl get all,cm,secret,ing -A
```

Check:

* Pods are in `Running` state
* Services are created
* ConfigMaps and Secrets exist
* Ingress (if defined) is present

---

## 9. Validate Namespace Configuration

Ensure namespaces match values.yaml:

```bash
kubectl get ns
```

---

## 10. Validate Secrets

```bash
kubectl get secrets -A
kubectl describe secret todoapp-app-secret -n todoapp
```

```bash
kubectl get secrets -A
kubectl describe secret mysql-secrets -n mysql
```

Check:

* Secrets exist
* Data is populated correctly

---

## 11. Validate Deployment Configuration

```bash
kubectl describe deployment todoapp-todoapp -n todoapp
```

Verify:

* Image repo and tag
* Resource limits/requests
* Environment variables from secrets
* Rolling update strategy
* ServiceAccount usage

---

## 12. Validate HPA

```bash
kubectl get hpa -A
kubectl describe hpa todoapp-todoapp -n todoapp
```

Check:

* Min/Max replicas
* CPU/Memory targets

---

## 13. Validate Persistent Storage

```bash
kubectl get pv
kubectl get pvc -A
```

Check:

* Capacity matches values.yaml
* PVC is bound

---

## 14. Validate MySQL Sub-chart

```bash
kubectl get statefulsets -A
kubectl describe statefulset mysql-stateful -n mysql
```

Check:

* Replicas count
* Volume claims
* Resources
* Affinity / tolerations

---

## 15. Validate Node Scheduling Rules

Check pod placement:

```bash
kubectl get pods -o wide -A
```

Ensure:

* MySQL pods respect taints/tolerations
* Todo app respects affinity rules

---

## 16. Validate Output Log

Ensure file exists:

```bash
cat output.log
```

File must contain:

```bash
kubectl get all,cm,secret,ing -A
```

---

