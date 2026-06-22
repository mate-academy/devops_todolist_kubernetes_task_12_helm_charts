kind create cluster --config cluster.yml &&
kubectl get nodes --show-labels &&
kubectl taint nodes -l app=mysql app=mysql:NoSchedule &&
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}" &&
helm dependency update .infrastructure/helm-chart/todoapp &&
helm install todoapp .infrastructure/helm-chart/todoapp
