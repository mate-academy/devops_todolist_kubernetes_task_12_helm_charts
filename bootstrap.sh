#!/bin/bash

# bootstrap.sh - Скрипт для розгортання передумов та Helm-чарту todoapp

# Вийти негайно, якщо команда завершується з ненульовим статусом.
set -e

echo "Початок розгортання Kubernetes за допомогою bootstrap скрипта..."


echo "--- Перевірка встановлення kubectl та Helm ---"
if ! command -v kubectl &> /dev/null
then
    echo "kubectl не встановлено. Будь ласка, встановіть kubectl та налаштуйте його для підключення до вашого Kubernetes кластера."
    exit 1
fi
if ! command -v helm &> /dev/null
then
    echo "Helm не встановлено. Будь ласка, встановіть Helm (https://helm.sh/docs/intro/install/)."
    exit 1
fi

echo "kubectl та Helm встановлено."


echo "--- Перевірка наявності StorageClass 'standard' ---"
if kubectl get storageclass standard &> /dev/null; then
    echo "StorageClass 'standard' вже існує."
else
    echo "StorageClass 'standard' не знайдено. Спроба створити базовий StorageClass 'standard'."
    cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: k8s.io/minikube-hostpath # <--- ЗМІНІТЬ ЦЕЙ РЯДОК, ЯКЩО НЕ ВИКОРИСТОВУЄТЕ MINIKUBE
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF
    echo "StorageClass 'standard' створено. Переконайтеся, що він підходить для вашого середовища."
    echo "Якщо використовуєте хмарний провайдер, вам може знадобитися змінити 'provisioner' на, наприклад, 'kubernetes.io/aws-ebs' для AWS, 'kubernetes.io/gce-pd' для GCP або 'kubernetes.io/azure-disk' для Azure."

fi



echo "--- Розгортання Helm-чарту MySQL ---"


MYSQL_CHART_PATH="./.infrastructure/helm-chart/todoapp/charts/mysql"
MYSQL_VALUES_PATH="./.infrastructure/helm-chart/todoapp/charts/mysql/values.yaml"
MYSQL_RELEASE_NAME="mysql-database"

echo "Розгортання MySQL з: ${MYSQL_CHART_PATH}"
echo "Використання значень MySQL з: ${MYSQL_VALUES_PATH}"


helm upgrade --install ${MYSQL_RELEASE_NAME} ${MYSQL_CHART_PATH} \
  -f ${MYSQL_VALUES_PATH} \
  --namespace mysql \
  --create-namespace \
  --atomic \
  --wait

echo "Helm-чарт MySQL успішно розгорнуто."


echo "--- Розгортання Helm-чарту Todoapp ---"

TODOAPP_CHART_PATH="./.infrastructure/helm-chart/todoapp"
TODOAPP_VALUES_PATH="./.infrastructure/helm-chart/todoapp/values.yaml"
TODOAPP_RELEASE_NAME="todoapp" # Назва релізу для todoapp

echo "Розгортання Todoapp з: ${TODOAPP_CHART_PATH}"
echo "Використання значень Todoapp з: ${TODOAPP_VALUES_PATH}"

helm upgrade --install ${TODOAPP_RELEASE_NAME} ${TODOAPP_CHART_PATH} \
  -f ${TODOAPP_VALUES_PATH} \
  --namespace todoapp \
  --create-namespace \
  --atomic \
  --wait # Чекайте, доки розгортання буде готовим

echo "Helm-чарт Todoapp успішно розгорнуто."

echo "Bootstrap скрипт завершено."
echo "Тепер ви можете перевірити свої розгортання за допомогою: kubectl get all -A"