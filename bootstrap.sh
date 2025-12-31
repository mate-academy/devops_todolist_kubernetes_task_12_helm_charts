kubectl taint node kind-worker kind-worker2 app=mysql:NoSchedule
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
helm install todoapp-release .infrastructure/helm-chart/todoapp