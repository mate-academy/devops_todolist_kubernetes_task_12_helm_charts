kind create cluster --config cluster.yml &&
kubectl taint nodes kind-worker2 kind-worker app=mysql:NoSchedule &&
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}" &&
helm install todoapp .infrastructure/helm-chart/todoapp
