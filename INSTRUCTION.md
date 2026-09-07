# Інструкція з розгортання та перевірки todoapp
Документ містить кроки для запуску автоматичного деплою додатка в Kind-кластер, валідації створених Kubernetes-ресурсів та збереження підсумкових логів.
---
## 1. Запуск деплою
1. **Запустіть автоматичне розгортання:**


```bash
chmod +x bootstrap.sh
./bootstrap.sh

2. Завантажте локальний Docker-образ у Kind-кластер:
kind load docker-image olexandrkv/todoapp:latest --name kind

3. Перевірка деплою:
Перевірте що всі ресурси розгорнуті:
kubectl get all,cm,secret,ing -A

Перевірте що поди працюють:
kubectl get pods -n todoapp
kubectl get pods -n mysql

Перевірте що HPA створений:
kubectl get hpa -n todoapp

Перевірте що PVC прив'язані:
kubectl get pvc -A

4. Збереження результатів перевірки
Згенеруйте лог стану всіх ресурсів:
kubectl get all,cm,secret,ing -A > output.log
