# Cluster and Helm Setup Instructions

## 1. Run Bootstrap Script

Run the bootstrap script to initialize the setup:

```bash
./bootstrap.sh
```

---

## 2. Verify Node Changes

Check that the taints were applied correctly:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels}{"\t"}{.spec.taints}{"\n"}{end}'
```

---

## 3. Inspect the Cluster

To see how the cluster is functioning, see output.log
