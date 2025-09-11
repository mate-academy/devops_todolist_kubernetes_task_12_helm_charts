# створити кластер
kind create cluster --config ./cluster.yml --name todo
kubectl config use-context kind-todo
kubectl get nodes -o wide

# задеплоїти
helm dependency update helm-chart/todoapp
./bootstrap.sh

# перевірка і лог для CI
kubectl get all,cm,secret,ing -A | tee output.log
