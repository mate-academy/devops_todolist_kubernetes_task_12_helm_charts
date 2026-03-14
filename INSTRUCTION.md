# Validation Guide

## Prerequisites
- `kind`, `kubectl`, `helm`, Docker Desktop (or Docker daemon)

## 1) Bootstrap everything
`./bootstrap.sh`
- **What it does:**
  - creates/uses `kind` cluster from `cluster.yml`
  - inspects node labels and taints
  - taints nodes with `app=mysql:NoSchedule`
  - installs ingress-nginx prerequisite
  - installs/upgrades Helm release `todoapp`
  - writes `kubectl get all,cm,secret,ing -A` to `output.log`

## 2) Verify cluster topology
`kubectl get nodes -o wide --show-labels`
- **What it does:** confirms worker nodes are labeled (`app=mysql`, `app=todoapp`).


## 3) Verify taints for MySQL nodes
`kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints`
- **What it does:** confirms mysql nodes are tainted with `app=mysql:NoSchedule`.

## 4) Verify Helm release and charts
- **Action:** `helm list -n todoapp`
- **What it does:** confirms `todoapp` release is deployed.

`helm lint helm-chart/todoapp`
- **What it does:** validates chart syntax and structure.

## 5) Verify deployed application resources
 `kubectl get all,cm,secret,ing -A`
- **What it does:** confirms Deployments, StatefulSets, Services, HPA, ConfigMaps, Secrets, Ingress.


`kubectl get deploy -n todoapp && kubectl get sts -n mysql`
- **What it does:** confirms app Deployment and mysql StatefulSet are running.


## 6) Verify key Helm requirements directly
`helm template todoapp helm-chart/todoapp | less`
- **What it does:** renders manifests to confirm:
  - `.Chart.Name` prefixes in names
  - namespace from values
  - secret `data` populated via `range`
  - deployment secret envs mapped via `range`
  - resources, rolling update, image, affinity, HPA, PV/PVC, service account values are parameterized


## 7) Check output artifact
`cat output.log`
- **What it does:** confirms required command output was saved in repository root.

## 8) Optional smoke test
`kubectl get pods -n todoapp -w`
- **What it does:** tracks pod readiness in real time.
