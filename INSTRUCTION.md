#### Create cluster
kind create cluster --config cluster.yml

#### Taint nodes labeled
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

#### Deploy using helm
helm install todoapp .infrastructure/helm-chart/todoapp