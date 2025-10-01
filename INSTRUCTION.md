# Validation Instructions

1. Make sure kind cluster is running:
   kubectl get nodes

2. Deploy prerequisites and helm charts:
   ./bootstrap.sh

3. Check all pods are running:
   kubectl get pods -n todoapp

4. Check services, secrets, configmaps, ingresses:
   kubectl get all,cm,secret,ing -A