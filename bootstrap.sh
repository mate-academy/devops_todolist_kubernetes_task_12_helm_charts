kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm dependency build .infrastructure/helm-chart/todoapp
sleep 2m
helm install todoapp .infrastructure/helm-chart/todoapp
sleep 23m
kubectl get all,cm,secret,ing -A > output.log
