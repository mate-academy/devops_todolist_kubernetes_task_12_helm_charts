# How to validate the changes

## Prerequisites

- Docker
- kind
- kubectl
- helm v3

All commands are executed from the repository root.

# Create kind cluster

```bash
kind create cluster --name todolist --config cluster.yml


¹ Deploy ingress controller and Helm charts
chmod +x bootstrap.sh
./bootstrap.sh

# Validate Kubernetes resources
# Check that all resources are created:

kubectl get all,cm,secret,ing -A

# Save the output to output.log:

kubectl get all,cm,secret,ing -A > output.log

# Check node labels and taints:
kubectl get nodes --show-labels
kubectl describe node <node-name>

# Cleanup
# To delete the cluster:
kind delete cluster --name todolist