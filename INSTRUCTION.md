# INSTRUCTION.md

tools:

* Docker
* kubectl
* Helm
* kind (Kubernetes in Docker)



1. Create Kubernetes Cluster

Create a kind cluster using the provided configuration:

```bash
kind create cluster --config .infrastructure/cluster.yml
```

Verify cluster is running:

```bash
kubectl get nodes
```

Expected output: node in `Ready` state.

---

2. Inspect Nodes

Check node labels:

```bash
kubectl get nodes --show-labels
```

---

3. Apply Taints

Taint nodes labeled with `app=mysql`:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Verify taints:

```bash
kubectl describe nodes | grep Taints
```

---

4. Prepare Helm Chart

Update dependencies:

```bash
helm dependency update .infrastructure/helm-chart/todoapp
```

Validate Helm chart:

```bash
helm lint .infrastructure/helm-chart/todoapp
```

Render templates:

```bash
helm template todoapp .infrastructure/helm-chart/todoapp
```

---

5. Deploy Application

Install Helm chart:

```bash
helm install todoapp .infrastructure/helm-chart/todoapp
```

Verify resources:

```bash
kubectl get pods
kubectl get svc
kubectl get statefulset
```

Expected:

* `todoapp` pod is running
* `mysql-0` pod is running

---

6. Validate Kubernetes Resources

Run the command:

```bash
kubectl get all,cm,secret,ing -A
```

Ensure the following resources exist:

* Pods (todoapp, mysql)
* Services
* ConfigMaps
* Secrets
* Ingress (if enabled)

---

7. Save Output

Save output to a file in the root of the repository:

### Windows (CMD):

```bash
kubectl get all,cm,secret,ing -A > output.log
```

### PowerShell:

```bash
kubectl get all,cm,secret,ing -A | Out-File output.log
```

### Linux/Mac:

```bash
kubectl get all,cm,secret,ing -A > output.log
```

---

8. Final Validation Checklist

* Cluster is running
* Nodes have correct labels and taints
* Helm chart installs successfully
* MySQL StatefulSet is running
* Secrets are created correctly
* Resources use `.Chart.Name` prefix
* Values are controlled via `values.yaml`
* `output.log` file exists in project root

---


### Recreate cluster

```bash
kind delete cluster
kind create cluster --config .infrastructure/cluster.yml
```

### Helm issues

```bash
helm lint .
helm template .
```
