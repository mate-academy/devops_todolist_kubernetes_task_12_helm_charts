Ось базовий приклад для INSTRUCTION.md:
# Інструкція для перевірки розгортання

# Підключіться до кластеру Kubernetes (kind):
kubectl cluster-info

# Перевірте ресурси в namespace `mysql`:
kubectl get all -n mysql

#  Перевірте ресурси в namespace `todoapp`:
kubectl get all -n todoapp

# Перегляньте створені secrets:
kubectl get secrets -A

# Перевірте, що всі поди працюють без помилок:
kubectl get pods -A
kubectl describe pod <pod_name> -n <namespace>

# Перегляньте логи у файл `output.log` у корені репозиторію.
# Якщо все працює — деплоймент успішний!