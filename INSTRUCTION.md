## Kubernetes task 12 — Helm charts (todoapp + mysql)

### Prerequisites
1. Ensure `kind`, `kubectl` and `helm` are installed.
2. Create a `kind` cluster from `cluster.yml`.

### Deploy
1. Start the cluster:
```bash
kind create cluster --config cluster.yml
```

2. Inspect Nodes for Labels and Taints:
```bash
kubectl get nodes --show-labels
kubectl describe nodes | head -n 60
```

3. Taint nodes labeled with `app=mysql` with `app=mysql:NoSchedule`:
```bash
for n in $(kubectl get nodes -l app=mysql -o name); do
  kubectl taint "$n" app=mysql:NoSchedule --overwrite
done
```

4. Deploy the Helm chart:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### Validate
1. Check that `output.log` exists in the repo root and contains the result of:
```bash
kubectl get all,cm,secret,ing -A
```

2. Verify main application resources:
```bash
kubectl -n todoapp get deploy,svc,hpa,pvc,secret,configmap,sa
```

3. Verify MySQL sub-chart resources:
```bash
kubectl -n mysql get sts,svc,secret,configmap
```

