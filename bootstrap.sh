#!/bin/bash
set -e

echo "=== 1. Запуск кластера Kind ==="
kind create cluster --config cluster.yml

echo "=== 2. Додавання Taints на ноди бази даних ==="
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items.metadata.name}' 2>/dev/null || echo "")
if [ -n "$MYSQL_NODE" ]; then
  kubectl taint nodes $MYSQL_NODE app=mysql:NoSchedule --overwrite
  echo "Taint app=mysql:NoSchedule успішно встановлено на $MYSQL_NODE"
else
  echo "Увага: Ноду з міткою app=mysql не знайдено в конфігурації кластера."
fi

echo "=== 3. Перевірка та розгортання Helm-чарту ==="
kubectl create namespace todoapp || true
helm install todoapp ./helm-chart/todoapp -n todoapp

echo "=== 4. Створення лог-файлу для валідації завдання ==="
sleep 5
kubectl get all,cm,secret,ing -A > output.log
echo "Файл output.log успішно згенеровано!"
