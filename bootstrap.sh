kind create cluster --config cluster.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml

helm dependency build .infrastructure/helm-chart/todoapp
helm install todoapp .infrastructure/helm-chart/todoapp
