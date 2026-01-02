# Інструкція з розгортання додатку

Перед тим як розпочати розгортання, потрібно видалити всі старі ресурси:
```
kind delete cluster 
```

Для того аби розгорнути додаток, виконайте наступні кроки:
1. Потрібно запустити скрипт bootstrap.sh:
```
./bootstrap.sh
```

Скрипт автоматично створить кластер `kind`, налаштує всі необхідні ресурси та розгорне додаток.

2. Потрібно перевірити готовність подів та інших ресурсів:
```
kubectl get pods --all-namespaces
kubectl get svc --all-namespaces
kubectl get pvc --all-namespaces
kubectl get hpa --all-namespaces
kubectl get deployments --all-namespaces
kubectl get statefulsets --all-namespaces
```

3. Після успішного розгортання, додаток буде доступний за адресою:
```
http://localhost:30007
```

