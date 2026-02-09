## Step-by-Step Deployment Instructions

### 1. Create the KinD Cluster
```bash
kind create cluster --config cluster.yml
kubectl cluster-info
kubectl get nodes
```

### 2. Deploy Using Helm
```bash
cd .infrastructure/helm-chart/todoapp
helm dependency update
helm install todoapp . --create-namespace
kubectl get pods -A -w
```

---

## Verification

```bash
kubectl get all,cm,secret,ing -A > output.log
cat output.log
```
