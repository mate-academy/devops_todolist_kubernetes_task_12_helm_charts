# How to validate the changes

## Prerequisites

- Docker (running), `kind`, `kubectl`, `helm`
- Free ports `80`, `443`, `30007`, `30008` on the host (they are published by the kind control-plane node)
- A Bash shell (Git Bash on Windows)

## 1. Deploy

Run from the repository root:

```bash
bash bootstrap.sh
```

The script is idempotent and does everything in order (it refuses to continue unless the
current context is a `kind-*` one):

1. creates the kind cluster `todo` from `cluster.yml` (skipped if it already exists);
2. prints node labels and taints, taints nodes labeled `app=mysql` with `app=mysql:NoSchedule`
   and prints the taints again;
3. installs the ingress-nginx controller (kind flavour) and waits for it;
4. installs metrics-server (patched with `--kubelet-insecure-tls`) so that the HPA gets metrics;
5. runs `helm dependency update` and `helm upgrade --install todoapp helm-chart/todoapp`
   (the `mysql` sub-chart in `charts/mysql` is deployed together with it);
6. runs `kubectl get all,cm,secret,ing -A` and saves the output to `output.log`
   in the repository root.

The first run can take several minutes because of image pulls.

To do the first steps by hand instead:

```bash
kind create cluster --config cluster.yml --name todo
kubectl get nodes --show-labels
kubectl describe nodes | grep -E '^(Name|Taints):'
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
kubectl describe nodes | grep -E '^(Name|Taints):'
```

`todo-worker` and `todo-worker2` must show `Taints: app=mysql:NoSchedule`.

Namespaces are named `<chart name>-<value from values.yaml>`, i.e. `todoapp-todoapp`
and `mysql-mysql` with the default values.

## 2. Verify

Chart checks (the same ones the CI workflow runs):

```bash
helm lint helm-chart/todoapp
helm template helm-chart/todoapp -f helm-chart/todoapp/values.yaml
```

Cluster state:

```bash
kubectl get pods -n mysql-mysql -o wide      # mysql-0 and mysql-1, Running, on the nodes labeled app=mysql
kubectl get pods -n todoapp-todoapp -o wide    # 2 x todoapp, Running
kubectl get hpa,ing -n todoapp-todoapp         # HPA "todoapp" with real CPU/memory targets, Ingress "todoapp-ingress"
kubectl get all,cm,secret,ing -A > output.log
python .github/workflows/scripts/validate-output.py   # every line must be True
```

## 3. Check that everything is driven by `values.yaml`

Everything below is controlled from `helm-chart/todoapp/values.yaml`
(and `helm-chart/todoapp/charts/mysql/values.yaml` for MySQL):
namespace, secrets (rendered with `range`, also used as env variables with `range`),
resources, RollingUpdate parameters, image repository/tag, node affinity, HPA limits and
CPU/memory targets, PV/PVC size, ServiceAccount name (Deployment and all RBAC objects);
for MySQL also replicas, storage, affinity and tolerations.

Example: render with a different replica count and check the result.

```bash
helm template helm-chart/todoapp --set mysql.replicas=3 | grep -n "replicas"
```

(`helm template` with a changed value is the quickest way to prove a parameter is wired to `values.yaml`.)

## 4. Clean up

```bash
helm uninstall todoapp
kind delete cluster --name todo
```
