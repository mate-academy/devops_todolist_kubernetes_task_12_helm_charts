# Tains check
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"

# Helm chart deployment check
helm list -A
helm dependency list ./helm-chart/todoapp
kubectl get all -n todoapp
kubectl get all -n mysql
kubectl get statefulset -n mysql
kubectl get pvc -n todoapp
kubectl get deployment -n todoapp
kubectl get hpa -n todoapp
kubectl describe secret todoapp-secret -n todoapp
kubectl describe secret mysql-secret -n mysql
kubectl get serviceaccount -n todoapp
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
kubectl get pods -n todoapp -o wide

# Application check
kubectl port-forward service/todoapp-service 8080:80 -n todoapp
http://localhost:8080