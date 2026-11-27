# Інструкція з розгортання TodoApp за допомогою Helm

## 1. Призначення

Проєкт розгортає Django-застосунок **TodoApp** та базу даних **MySQL 8.0** у локальному Kubernetes-кластері **kind**. Для керування ресурсами використовується Helm: головний Chart `helm-chart/todoapp` містить ресурси застосунку, а дочірній Chart `helm-chart/todoapp/charts/mysql` — ресурси MySQL.

Після встановлення застосунок працює в namespace `todoapp`, MySQL — у namespace `mysql`.

## 2. Необхідні інструменти

Перед початком перевірте, що встановлено й запущено:

- Docker Desktop (Docker Engine);
- `kind`;
- `kubectl`;
- `helm`;
- `bash`.

Перевірка:

```bash
docker info
kind version
kubectl version --client
helm version
```

Усі наведені нижче команди потрібно виконувати **з кореневої директорії репозиторію**.

## 3. Створення Kubernetes-кластера

Якщо кластер ще не створений, виконайте:

```bash
kind create cluster --name todoapp-helm --config cluster.yml
kubectl config use-context kind-todoapp-helm
kubectl get nodes
```

> Якщо кластер `todoapp-helm` уже існує, повторно створювати його не потрібно.

Для коректного розміщення Pod налаштуйте labels вузлів. Нижче наведено приклад для кластера з вузлами `worker`, `worker2`, `worker3`, `worker4` і `worker5`:

```bash
kubectl label node todoapp-helm-worker app=mysql --overwrite
kubectl label node todoapp-helm-worker2 app=mysql --overwrite
kubectl label node todoapp-helm-worker3 app=todoapp --overwrite
kubectl label node todoapp-helm-worker4 app=todoapp --overwrite
kubectl label node todoapp-helm-worker5 app=todoapp --overwrite
kubectl get nodes -L app
```

Якщо назви вузлів відрізняються, використовуйте назви з виводу `kubectl get nodes`. Два вузли MySQL повинні мати label `app=mysql`, а вузли застосунку — `app=todoapp`. MySQL-вузли також мають taint `app=mysql:NoSchedule`; `bootstrap.sh` налаштовує цей taint автоматично.

## 4. Конфігурація Helm

Перед встановленням перевірте параметри:

- `helm-chart/todoapp/values.yaml` — namespace, образ Django, параметри Deployment, HPA, PVC, Secret, node affinity;
- `helm-chart/todoapp/charts/mysql/values.yaml` — namespace MySQL, образ, кількість реплік, Secret, ресурси, сховище, tolerations та affinity.

Для підключення Django до бази перевірте узгодженість параметрів:

| Параметр TodoApp | Значення / зв'язок із MySQL |
| --- | --- |
| `DB_NAME` | Назва бази даних, наприклад `app_db` |
| `DB_USER` | Відповідає `MYSQL_USER` |
| `DB_PASSWORD` | Відповідає `MYSQL_PASSWORD` |
| `DB_HOST` | `mysql-0.mysql.mysql.svc.cluster.local` |
| `SECRET_KEY` | Окремий секретний ключ Django |

`DB_HOST` спрямовано на `mysql-0`, оскільки в цьому навчальному проєкті **не налаштовано реплікацію MySQL** між двома Pod StatefulSet. Перевірте, що MySQL ініціалізовано з відповідною базою та користувачем.

**Безпека:** не додавайте справжні паролі або секретні ключі до публічного репозиторію. Для реального середовища використовуйте окремий захищений спосіб керування Secrets.

## 5. Розгортання через bootstrap.sh

Перевірте синтаксис скрипта:

```bash
bash -n bootstrap.sh
```

Запустіть:

```bash
bash bootstrap.sh
```

Скрипт виконує такі дії:

1. Вибирає контекст `kind-todoapp-helm`.
2. Налаштовує taint для вузлів MySQL.
3. Встановлює NGINX Ingress Controller та очікує його готовності.
4. Встановлює Metrics Server для HPA (для локального kind застосовується `--kubelet-insecure-tls`).
5. Оновлює залежності Helm та перевіряє Chart командою `helm lint`.
6. Встановлює або оновлює release `todoapp-release` разом із дочірнім Chart MySQL.
7. Виводить стан основних ресурсів.

Перший запуск може тривати довше через завантаження Docker-образів. Якщо команда завершується за таймаутом, перевірте фактичний стан ресурсів і логи Pod, **не видаляючи кластер або сховища**.

Альтернативне ручне встановлення (у вже підготовленому кластері):

```bash
helm dependency update ./helm-chart/todoapp
helm lint ./helm-chart/todoapp
helm upgrade --install todoapp-release ./helm-chart/todoapp \
  --namespace default --wait --timeout 10m
```

## 6. Перевірка результату

```bash
helm status todoapp-release
kubectl get pods -n todoapp
kubectl get pods -n mysql
kubectl get svc -n todoapp
kubectl get svc -n mysql
kubectl get ingress -n todoapp
kubectl get hpa -n todoapp
kubectl get pvc -A
```

Очікуваний результат: `helm status` показує `STATUS: deployed`; Django Pod мають статус `1/1 Running`, MySQL Pod — `1/1 Running`. Застосунок має HTTP-ендпоїнти `/api/health` і `/api/ready`. Ендпоїнт `/api/ready` навмисно може повертати HTTP 500 протягом перших 30 секунд після запуску контейнера, а потім HTTP 200.

Для діагностики:

```bash
kubectl logs -n todoapp deployment/todoapp --tail=100
kubectl describe deployment todoapp -n todoapp
kubectl get events -n todoapp --sort-by=.lastTimestamp
kubectl get events -n mysql --sort-by=.lastTimestamp
```

## 7. Збереження результатів у output.log

З кореневої директорії репозиторію виконайте:

```bash
kubectl get all,cm,secret,ing -A > output.log
```

Перевірте наявність файлу:

```bash
ls -lh output.log
```

Файл `output.log` містить перелік ресурсів Kubernetes в усіх namespaces. Команда показує метадані Secrets, **а не їх значення**.

## 8. Структура основних файлів

```text
.
├── bootstrap.sh
├── cluster.yml
├── helm-chart/
│   └── todoapp/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── templates/
│       └── charts/
│           └── mysql/
│               ├── Chart.yaml
│               ├── values.yaml
│               └── templates/
├── INSTRUCTION.md
└── output.log
```

## 9. Оновлення та видалення release

Після зміни конфігурації Chart:

```bash
helm upgrade todoapp-release ./helm-chart/todoapp
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
```

Для видалення Helm release:

```bash
helm uninstall todoapp-release --namespace default
```

**Увага:** видалення release, PVC або кластера може призвести до втрати даних. Не видаляйте сховища без необхідності.
