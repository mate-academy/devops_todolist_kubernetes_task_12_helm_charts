kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml

helm install todoapp helm-chart/todoapp
