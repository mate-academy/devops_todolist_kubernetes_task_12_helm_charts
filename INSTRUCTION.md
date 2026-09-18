# Create Helm Chart for a todoapp

## Prerequisites
* `kind` cluster running
* Namespace `todoapp`

## Deploy

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### Step 1: Verify Cluster Nodes, Labels, and Taints:

```bash
# Inspect nodes for Labels
kubectl get nodes --show-labels

# Inspect nodes for Taints
kubectl get nodes -l app=todoapp -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Add taint as `app=mysql:NoSchedule` for nodes with label as `app=mysql`
kubectl taint nodes <worker-node-name> app=mysql:NoSchedule

# Expected: 2 nodes labeled as `app=mysql` with taint `app=mysql:NoSchedule`
```

### Step 2. Validation Instructions

```bash
# Create `todoapp` chart name inside a `helm-chart` directory
helm create todoapp

# Create a sub-chart called `mysql` inside a `charts` directory of the `todoapp` helm chart
helm create mysql

# Validate the `todoapp` parent chart:
helm lint ./.infrastructure/helm-chart/todoapp

# Validate the `mysql` subchart:
helm lint ./.infrastructure/helm-chart/todoapp/charts/mysql

# Render the `todoapp` parent chart together with the `mysql` subchart:
helm template todoapp ./.infrastructure/helm-chart/todoapp

# Install the `todoapp` Helm Chart
#helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp
helm install todoapp ./.infrastructure/helm-chart/todoapp -n todoapp --create-namespace

# Check the `todoapp` release name installed:
helm list -A
helm list -n todoapp

# Check pods for `todoapp` application and `mysql` server
kubectl get pods -n todoapp
kubectl get pods -n todoapp

# Check deployed all resources
kubectl get all,cm,secret,ing -A

# Make sure `todoapp` application by the http://localhost:8083/ URL is available and working
kubectl port-forward -n todoapp deployment/todoapp 8083:8080

# Save the deployment to the `output.log`  file
kubectl get all,cm,secret,ing -A > output.log
```