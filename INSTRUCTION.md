# First, ensure the nodes have the label
kubectl label nodes kind-worker kind-worker2 app=mysql --overwrite

# Then, taint nodes using the label selector
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# install chart
helm install todoapp-release .infrastructure/helm-chart/todoapp

# check chart is  started
helm list -A
kubectl get pods -n mysql
kubectl get pods -n todoapp
kubectl get services

# check site is accessible
http://localhost:30007/
http://localhost
