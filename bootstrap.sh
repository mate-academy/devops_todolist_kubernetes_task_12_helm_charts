#!/bin/bash

# Налаштування змінних
HELM_CHART_PATH="./.infrastructure/helm-chart/todoapp"
NAMESPACE="todoapp"
RELEASE_NAME="todoapp-release"

echo "🛠️ Починаємо підготовку Kubernetes та розгортання Helm-чарту..."

# 1. Створення Namespace
echo "➡️ Створення Namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE || echo "Namespace $NAMESPACE вже існує."

# 2. Підготовка вузлів (якщо потрібно для affinity/tolerations)
echo "➡️ Додавання лейблів та толерантностей до вузлів (приклад: app=mysql, app=kube2py)"
# Приклад: Вам можуть знадобитися команди для додавання лейблів на вузли, 
# якщо це вимагається affinity/tolerations у values.yaml.
# kubectl label node <node-name> app=mysql --overwrite
# kubectl label node <node-name> app=kube2py --overwrite

# 3. Оновлення залежностей Helm (Критично для підчарту mysql)
echo "➡️ Оновлення залежностей Helm-чарту (helm dependency update)"
helm dependency update $HELM_CHART_PATH

# 4. Розгортання Helm-чарту
echo "➡️ Розгортання релізу Helm: $RELEASE_NAME у $NAMESPACE"
helm upgrade --install $RELEASE_NAME $HELM_CHART_PATH \
  --namespace $NAMESPACE \
  --atomic \
  --timeout 5m

# 5. Перевірка статусу розгортання (опціонально, але корисно)
echo "➡️ Очікування готовності Deployment та StatefulSet..."
kubectl wait --for=condition=Available deployment/$RELEASE_NAME --timeout=300s -n $NAMESPACE
kubectl wait --for=condition=Ready statefulset/mysql --timeout=300s -n $NAMESPACE

# 6. Збір виводу (КРИТИЧНО для перевірки ментором)
echo "▶️ Deployment complete. Getting status and writing to output.log..."
kubectl get all,cm,secret,ing -A > output.log

echo "✅ Deployment finished. Check output.log"