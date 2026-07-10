run bootstrap.sh
helm list
helm status todoapp-release
helm get values todoapp-release
helm get manifest todoapp-release
helm history todoapp-release
kubectl get all -n todoapp
kubectl get pvc -A
kubectl get pv
kubectl get secrets -A
kubectl get configmaps -A
kubectl get ingress -A
kubectl get hpa -A
kubectl get serviceaccounts -A
kubectl get pods -A