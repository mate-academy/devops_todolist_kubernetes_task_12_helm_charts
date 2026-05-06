# Validation Instructions
## Prerequisites
- kind cluster running
- kubectl installed
- helm installed


## Deploy
```bash
./bootstrap.sh
Validate

Check all resources are deployed:

kubectl get all,cm,secret,ing -A

Check helm release:

helm list -A

Check PV and PVC:

kubectl get pv,pvc -A

Check pods are running:

kubectl get pods -A

Check HPA:

kubectl get hpa -A
Expected Results

todoapp deployment running in todoapp-ns
mysql statefulset running in todoapp-ns
PV and PVC bound
HPA created with min/max replicas from values.yaml