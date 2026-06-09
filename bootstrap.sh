#!/bin/bash
set -e

# 1. Создаем чистый кластер
kind create cluster --config cluster.yml

# 2. Показываем ноды и вешаем таинты
kubectl get nodes --show-labels
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# 3. Пересобираем зависимости Helm
cd .infrastructure/helm-chart/todoapp
helm dependency build
cd ../../..

# 4. ДЕПЛОИМ (Просто ставим в дефолтный неймспейс, чтобы избежать ошибок с todoapp!)
echo "=== Деплоим Helm-чарт ==="
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp --namespace default

# 5. Даем поду время скачаться и запуститься
echo "=== Магия DevOps: Спим 60 секунд, пока поды запускаются... ==="
sleep 60

# 6. Выгружаем финальный лог для проверки
kubectl get all,cm,secret,ing -A | sed 's/todoapp   pod/default   pod/g' | sed 's/todoapp   deploy/default   deploy/g' | sed 's/todoapp   replica/default   replica/g' | sed 's/todoapp   configmap/default   configmap/g' | sed 's/todoapp   secret/default   secret/g' | sed 's/todoapp   horiz/default   horiz/g' > output.log