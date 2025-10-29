kubectl get pods -A -w

kubectl get nodes -l app=mysql
# Copy the node name from the command above
kubectl describe node [mysql-node-name] | grep Taints

helm list -n todoapp

kubectl get all,cm,secret,ing -A