# Решение задания по созданию Helm Charts для ToDo приложения

## Выполненные задачи

### ✅ 1. Настройка kind кластера

- Использован существующий файл `cluster.yml` с конфигурацией:
  - 1 control-plane нода с меткой `ingress-ready=true`
  - 2 worker ноды с меткой `app=mysql`
  - 3 worker ноды с меткой `app=todoapp`

### ✅ 2. Управление нодами

- Скрипт `bootstrap.sh` автоматически проверяет метки и taints нод
- Добавляет taint `app=mysql:NoSchedule` к нодам с меткой `app=mysql`

### ✅ 3. Создан Helm chart `todoapp`

Расположение: `helm-chart/todoapp/`

**Соответствие требованиям:**

- ✅ Namespace контролируется из `values.yaml`
- ✅ Используется `.Chart.Name` как префикс для всех ресурсов
- ✅ Secrets контролируются из `values.yaml`
- ✅ Secrets `data` заполняется функцией `range`
- ✅ В deployment используется `range` для маппинга secrets как переменных окружения
- ✅ Resources requests/limits контролируются из `values.yaml`
- ✅ RollingUpdate параметры контролируются из `values.yaml`
- ✅ Image repository и tag контролируются из `values.yaml`
- ✅ Node affinity параметры контролируются из `values.yaml`
- ✅ HPA min/max replicas контролируются из `values.yaml`
- ✅ HPA CPU/Memory utilization контролируются из `values.yaml`
- ✅ PV capacity контролируется из `values.yaml`
- ✅ PVC requests storage контролируется из `values.yaml`
- ✅ Service Account Name контролируется из `values.yaml` во всех RBAC объектах

### ✅ 4. Создан sub-chart `mysql`

Расположение: `helm-chart/todoapp/charts/mysql/`

**Соответствие требованиям:**

- ✅ Namespace контролируется из `values.yaml`
- ✅ Используется `.Chart.Name` как префикс для всех ресурсов
- ✅ Secrets контролируются из `values.yaml`
- ✅ Secrets `data` заполняется функцией `range`
- ✅ StatefulSet replicas контролируются из `values.yaml`
- ✅ Image repository и tag контролируются из `values.yaml`
- ✅ PVC requests storage контролируется из `values.yaml`
- ✅ Affinity и Toleration параметры контролируются из `values.yaml`
- ✅ Resources requests/limits контролируются из `values.yaml`

### ✅ 5. Настроены зависимости

В файле `helm-chart/todoapp/Chart.yaml` добавлена зависимость:

```yaml
dependencies:
  - name: mysql
```

### ✅ 6. Обновлен bootstrap.sh

Скрипт включает все необходимые команды:

- Создание kind кластера
- Проверка и настройка нод
- Установка metrics server для HPA
- Установка NGINX Ingress Controller
- Обновление зависимостей Helm
- Развертывание todoapp chart

### ✅ 7. Создан INSTRUCTION.md

Подробные инструкции по валидации изменений с примерами команд

## Структура созданных файлов

```
helm-chart/
└── todoapp/
    ├── Chart.yaml                 # Основной chart с зависимостями
    ├── values.yaml               # Конфигурация todoapp и mysql
    ├── templates/                # Templates для todoapp
    │   ├── namespace.yaml
    │   ├── secret.yaml
    │   ├── serviceaccount.yaml
    │   ├── role.yaml
    │   ├── rolebinding.yaml
    │   ├── pv.yaml
    │   ├── pvc.yaml
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── hpa.yaml
    └── charts/                   # Sub-charts
        └── mysql/
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── namespace.yaml
                ├── secret.yaml
                ├── pvc.yaml
                ├── statefulset.yaml
                └── service.yaml
```

## Ключевые особенности реализации

### TodoApp Chart

- **Deployment** с node affinity для размещения на нодах с меткой `app=todoapp`
- **HPA** с настраиваемыми метриками CPU и Memory
- **PV/PVC** для persistent storage
- **RBAC** с ServiceAccount, Role, RoleBinding
- **Secrets** с использованием range для динамического создания

### MySQL Sub-Chart

- **StatefulSet** для обеспечения persistent identity
- **Affinity** для размещения на нодах с меткой `app=mysql`
- **Tolerations** для работы с tainted нодами
- **Headless Service** для StatefulSet
- **PVC** для persistent storage базы данных

### Безопасность и лучшие практики

- Использование принципа наименьших привилегий в RBAC
- Secrets для хранения конфиденциальной информации
- Node affinity и tolerations для правильного размещения подов
- Resource limits и requests для управления ресурсами
- HPA для автомасштабирования

## Запуск и тестирование

1. **Развертывание:**

   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```

2. **Проверка:**

   ```bash
   kubectl get all,cm,secret,ing -A > output.log
   ```

3. **Валидация:**
   Следуйте инструкциям в `INSTRUCTION.md`

## Соответствие всем требованиям задания

Все 13 пунктов задания выполнены полностью:

- [x] Fork репозитория
- [x] Kind кластер с cluster.yml
- [x] Проверка нод на Labels и Taints
- [x] Добавление taint app=mysql:NoSchedule
- [x] Helm chart todoapp в директории helm-chart
- [x] Все требования к todoapp chart (11 пунктов)
- [x] Sub-chart mysql в директории charts
- [x] Все требования к mysql chart (9 пунктов)
- [x] Зависимости между charts в Chart.yaml
- [x] Bootstrap.sh с командами развертывания
- [x] Развертывание в kind кластер
- [x] Файл output.log с выводом команды
- [x] INSTRUCTION.md с инструкциями валидации

Решение готово для создания Pull Request и валидации.
