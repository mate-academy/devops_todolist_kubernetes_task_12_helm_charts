# Instructions

1. Створення кластера

kind create cluster --config cluster.yml

2. Встановлення helm-залежностей

helm dependency update helm-chart/todoapp

3. Деплой

helm upgrade --install todoapp helm-chart/todoapp --namespace todoapp --create-namespace

4. Перевірка ресурсів

kubectl get all,cm,secret,ing -A

5. Очікуваний результат:

Поди розгорнуті
HPA працює
PVC створений
Секрети передані через Helm