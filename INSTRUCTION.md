# Cluster and Helm Setup Instructions

## 1. Create the Cluster

To create a Kubernetes cluster, run:

```bash
kind create cluster --config cluster.yml
```

---

## 2. Inspect Nodes

To inspect nodes for labels and taints, run:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels}{"\t"}{.spec.taints}{"\n"}{end}'
```

---

## 3. Taint Nodes

To taint nodes with a specific label (e.g., MySQL nodes), run:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

---

## 4. Verify Node Changes

Check that the taints were applied correctly:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels}{"\t"}{.spec.taints}{"\n"}{end}'
```

---

## 5. Create Helm Chart

Create a directory for your Helm chart and generate a new chart:

```bash
cd .infrastructure
mkdir helm-chart
cd helm-chart
helm create todoapp
```

---

## 6. Clean Up Default Chart

* Delete all contents from `values.yaml`.
* Delete all files in the `templates` directory.

---

## 7. Create a Subchart for MySQL

Navigate to the `charts` directory and create a MySQL subchart:

```bash
cd .infrastructure/helm-chart/todoapp/charts
helm create mysql
```

---

## 8. Clean Up Subchart

* Delete all contents from `values.yaml`.
* Delete all files in the `templates` directory.

---

## 9. Run Bootstrap Script

Run the bootstrap script to initialize the setup:

```bash
./bootstrap.sh
```

---

## 10. Inspect the Cluster

To see how the cluster is functioning, run:

```bash
kubectl get all,cm,secret,ing -A
```
