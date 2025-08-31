# Инструкции по валидации развертывания ToDo приложения

## Предварительные требования

Убедитесь, что у вас установлены следующие инструменты:

- Docker
- kind (Kubernetes in Docker)
- kubectl
- Helm 3.x

## Шаги для валидации

### 1. Клонирование и подготовка

```bash
# Клонируйте репозиторий
git clone <repository-url>
cd devops_todolist_kubernetes_task_12_helm_charts

# Убедитесь, что bootstrap.sh исполняемый
chmod +x bootstrap.sh
```

### 2. Запуск развертывания

```bash
# Запустите скрипт развертывания
./bootstrap.sh
```

Скрипт выполнит следующие действия:

- Создаст kind кластер с конфигурацией из `cluster.yml`
- Проверит метки и taints на нодах
- Добавит taint `app=mysql:NoSchedule` к нодам с меткой `app=mysql`
- Установит metrics server для HPA
- Установит NGINX Ingress Controller
- Обновит зависимости Helm
- Развернет todoapp Helm chart с MySQL sub-chart

### 3. Проверка развертывания

После успешного выполнения скрипта выполните следующие команды для валидации:

```bash
# Проверьте статус всех ресурсов
kubectl get all,cm,secret,ing -A

# Проверьте статус нод и их taints
kubectl describe nodes

# Проверьте развертывание todoapp
kubectl get pods -n todoapp
kubectl get services -n todoapp

# Проверьте развертывание MySQL
kubectl get pods -n mysql
kubectl get services -n mysql

# Проверьте HPA
kubectl get hpa -n todoapp

# Проверьте PV и PVC
kubectl get pv
kubectl get pvc -A
```

### 4. Проверка функциональности

```bash
# Проверьте логи приложения
kubectl logs -n todoapp deployment/todoapp-deployment

# Проверьте логи MySQL
kubectl logs -n mysql statefulset/mysql-statefulset

# Проверьте подключение к базе данных
kubectl exec -it -n mysql mysql-statefulset-0 -- mysql -u todouser -ptodopass -e "SHOW DATABASES;"
```

### 5. Проверка affinity и tolerations

```bash
# Проверьте, что поды MySQL размещены на нодах с меткой app=mysql
kubectl get pods -n mysql -o wide

# Проверьте, что поды todoapp размещены на нодах с меткой app=todoapp
kubectl get pods -n todoapp -o wide

# Проверьте tolerations в подах MySQL
kubectl describe pod -n mysql mysql-statefulset-0 | grep -A 5 Tolerations
```

### 6. Проверка Helm charts

```bash
# Проверьте установленные Helm releases
helm list -A

# Проверьте статус todoapp release
helm status todoapp

# Проверьте значения, используемые в chart
helm get values todoapp
```

### 7. Тестирование автомасштабирования

```bash
# Создайте нагрузку для проверки HPA
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# В контейнере выполните:
while true; do wget -q -O- http://todoapp-service.todoapp.svc.cluster.local:8000; done

# В другом терминале наблюдайте за HPA
kubectl get hpa -n todoapp -w
```

### 8. Проверка структуры Helm chart

Убедитесь, что структура соответствует требованиям:

```bash
# Проверьте структуру todoapp chart
tree helm-chart/todoapp/

# Проверьте, что MySQL является sub-chart
ls -la helm-chart/todoapp/charts/

# Проверьте зависимости в Chart.yaml
cat helm-chart/todoapp/Chart.yaml
```

## Ожидаемые результаты

После успешного развертывания вы должны увидеть:

1. **Namespaces**: `todoapp` и `mysql`
2. **Deployments**: `todoapp-deployment` в namespace `todoapp`
3. **StatefulSets**: `mysql-statefulset` в namespace `mysql`
4. **Services**:
   - `todoapp-service` в namespace `todoapp`
   - `mysql-service` в namespace `mysql`
5. **HPA**: `todoapp-hpa` в namespace `todoapp`
6. **PV/PVC**: Persistent volumes для обоих приложений
7. **Secrets**: Секреты для конфигурации обоих приложений
8. **RBAC**: ServiceAccount, Role, RoleBinding для todoapp

## Устранение неполадок

### Если поды не запускаются:

```bash
# Проверьте события
kubectl get events -A --sort-by=.metadata.creationTimestamp

# Проверьте описание пода
kubectl describe pod <pod-name> -n <namespace>
```

### Если HPA не работает:

```bash
# Проверьте metrics server
kubectl get pods -n kube-system | grep metrics-server

# Проверьте метрики
kubectl top nodes
kubectl top pods -A
```

### Если есть проблемы с affinity/tolerations:

```bash
# Проверьте метки нод
kubectl get nodes --show-labels

# Проверьте taints нод
kubectl describe nodes | grep -A 3 Taints
```

## Очистка

Для удаления всех ресурсов:

```bash
# Удалите Helm release
helm uninstall todoapp

# Удалите kind кластер
kind delete cluster
```

## Файлы для проверки

- `output.log` - содержит вывод команды `kubectl get all,cm,secret,ing -A`
- `bootstrap.sh` - скрипт развертывания
- `helm-chart/todoapp/` - основной Helm chart
- `helm-chart/todoapp/charts/mysql/` - MySQL sub-chart
- `cluster.yml` - конфигурация kind кластера

Все требования из задания должны быть выполнены и могут быть проверены с помощью указанных выше команд.
