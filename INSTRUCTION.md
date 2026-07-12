# Validation instructions

## Prerequisites

Install Docker, Kind, kubectl, and Helm.

## Deploy and validate

Run:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script creates the Kind cluster when it does not exist, inspects node labels and taints, labels and taints the MySQL nodes, installs chart dependencies, deploys the `todoapp` chart, and writes the required Kubernetes resource listing to `output.log`.

Validate the chart separately with:

```bash
helm lint .infrastructure/helm-chart/todoapp
helm template .infrastructure/helm-chart/todoapp -f .infrastructure/helm-chart/todoapp/values.yaml
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
kubectl get all,cm,secret,ing -A
```
