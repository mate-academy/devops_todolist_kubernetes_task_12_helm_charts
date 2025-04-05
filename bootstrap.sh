#!/bin/bash

# Створіть кластер
#!/bin/bash

# Створіть кластер
kind create cluster --config cluster.yml

# Динамічне отримання імені ноди з лейблом app=mysql та застосування taint
NODE_NAME=$(kubectl get nodes -l app=mysql -o name)
kubectl taint node "$NODE_NAME" app=mysql:NoSchedule --overwrite

# Розгортання helm-чарту
helm upgrade --install todoapp helm-chart/todoapp

# Отримання всіх ресурсів і збереження у файл output.log
kubectl get all,cm,secret,ing -A > output.log


# Розгорніть ресурси для бази даних
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# Розгорніть ресурси для застосунку
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

# Розгорніть Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml

# Розгорніть helm-чарт (необов'язково, якщо ви хочете використовувати тільки існуючі ресурси)
# helm upgrade --install todoapp helm-chart/todoapp
