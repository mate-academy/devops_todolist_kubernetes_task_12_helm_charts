kind create cluster --config cluster.yml

kubectl get nodes --show-labels

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl apply -f metricsServer.yml

kubectl get all,cm,secret,ing -A > output.log

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f metricsServer.yml  # якщо є цей файл
kubectl get all,cm,secret,ing -A > output.log
helm install todoapp ./helm-chart/todoapp --namespace todoapp-ns --create-namespace
helm install todoapp .infrastructure/helm-chart/todoapp --namespace todoapp-ns --create-namespace
