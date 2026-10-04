# Helm chart: як перевірити виконане завдання

## Що створено

Основний chart розташований у:

```text
.infrastructure/helm-chart/todoapp
```

MySQL є локальним subchart/dependency:

```text
.infrastructure/helm-chart/todoapp/charts/mysql
```

`todoapp/Chart.yaml` явно оголошує dependency `mysql`. Коли Helm встановлює
parent chart, він рендерить Django і MySQL одним release.

## Звідки Helm бере параметри

Parent `values.yaml` контролює:

- Namespace і кількість Django Pods;
- repository/tag образу;
- Secret data;
- ServiceAccount та RBAC;
- requests/limits;
- RollingUpdate;
- key/values Node Affinity;
- HPA min/max та CPU/Memory utilization;
- PV capacity і PVC storage;
- Service та Ingress.

MySQL `values.yaml` контролює:

- Namespace і replicas StatefulSet;
- repository/tag образу;
- Secret data;
- requests/limits;
- PVC storage;
- toleration;
- Node Affinity та Pod Anti-Affinity.

Secret values у цьому навчальному проєкті вже закодовані Base64. Helm `range`
перетворює кожну пару key/value на поле в `Secret.data`. Інший `range` у
Deployment створює environment variable для кожного ключа Secret.

## 1. Статична перевірка

Запускай із кореня репозиторію:

```bash
cd /Users/a.majlo/Mate/Kuber/devops_todolist_kubernetes_task_12_helm_charts
```

Перевір скрипт і Git diff:

```bash
bash -n bootstrap.sh
git diff --check
```

Перевір chart:

```bash
helm lint .infrastructure/helm-chart/todoapp
```

Очікуй:

```text
1 chart(s) linted, 0 chart(s) failed
```

Подивись YAML, який згенерує Helm:

```bash
helm template todoapp .infrastructure/helm-chart/todoapp \
  --values .infrastructure/helm-chart/todoapp/values.yaml \
  > /tmp/todoapp-rendered.yaml

kubectl apply --dry-run=client --validate=false \
  -f /tmp/todoapp-rendered.yaml
```

`helm template` нічого не створює в кластері — він лише рендерить шаблони.

## 2. Створити правильний kind-кластер

`cluster.yml` створює два workers із `app=mysql`, три з `app=todoapp` та один
звичайний worker. Якщо старий навчальний кластер більше не потрібний:

```bash
kind delete cluster --name todo-cluster
kind create cluster --name todo-cluster --config cluster.yml
```

Увага: delete видаляє кластер і його дані.

Перевір:

```bash
kubectl config current-context
kubectl get nodes -L app,ingress-ready
```

Очікуваний context: `kind-todo-cluster`.

## 3. Встановити chart

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Скрипт:

1. додає `app=mysql:NoSchedule` на MySQL Nodes;
2. встановлює Ingress NGINX;
3. запускає controller на ingress-ready control-plane;
4. чекає готовності admission webhook;
5. виконує `helm upgrade --install` для parent chart;
6. чекає готовності workloads;
7. створює `output.log`.

Release зберігається в Namespace `default`, але chart створює application
resources у Namespaces `todoapp` і `mysql`, які задані у values.

## 4. Перевірити release

```bash
helm list -A
helm status todoapp --namespace default
```

Перевір усі ресурси:

```bash
kubectl get all,cm,secret,ing -A
```

Перевір Pods і Nodes:

```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl get nodes -L app
```

Очікування:

- `mysql-0` і `mysql-1` мають `Running` та знаходяться на різних mysql Nodes;
- щонайменше два `todoapp-*` Pods мають `Running` і знаходяться на різних Nodes;
- HPA `todoapp` існує;
- Ingress `todoapp-ingress` існує.

Перевір taint:

```bash
kubectl get nodes -l app=mysql \
  -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
```

## 5. Перевірити values і range

Secret data створена через `range`:

```bash
helm template todoapp .infrastructure/helm-chart/todoapp \
  | sed -n '/^kind: Secret$/,/^---$/p'
```

Environment variables Deployment також створені через `range`:

```bash
kubectl get deployment todoapp -n todoapp -o yaml
```

Перевір образ і resources:

```bash
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
```

Перевір ServiceAccount:

```bash
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'

kubectl get serviceaccount,role,rolebinding -n todoapp
```

## 6. Перевірити застосунок

```bash
curl --fail --show-error http://localhost/api/health
```

Очікуй:

```text
Health OK
```

Якщо Ingress ще не отримав адресу:

```bash
kubectl get ingress todoapp-ingress -n todoapp
kubectl get pods -n ingress-nginx -o wide
```

## 7. output.log

Завдання вимагає результат цієї команди в корені репозиторію:

```bash
kubectl get all,cm,secret,ing -A > output.log
```

`bootstrap.sh` робить це автоматично після успішного deployment. Перевір:

```bash
test -s output.log && echo "output.log exists and is not empty"
python .github/workflows/scripts/validate-output.py
```

## 8. Типові помилки

### MySQL Pods Pending

```bash
kubectl describe pod mysql-0 -n mysql
kubectl get nodes -L app
```

Перевір labels, taint, toleration та Node Affinity.

### todoapp readiness повертає 500

На першому старті MySQL ініціалізується, а Django виконує migrations. Подивись:

```bash
kubectl logs deployment/todoapp -n todoapp --tail=100
kubectl get pods -n mysql
```

### Ingress webhook connection refused

```bash
kubectl get pods,endpoints -n ingress-nginx
kubectl get validatingwebhookconfiguration ingress-nginx-admission
```

`bootstrap.sh` має bounded wait і не створює Ingress до готовності webhook.

## 9. Повторне встановлення і видалення

Змінити values і повторно застосувати:

```bash
helm upgrade todoapp .infrastructure/helm-chart/todoapp \
  --namespace default \
  --wait \
  --timeout=10m
```

Видалити release:

```bash
helm uninstall todoapp --namespace default
```

## 10. Git і Pull Request

```bash
git status
git diff
git diff --check
```

Додай конкретні результати завдання:

```bash
git add .infrastructure/helm-chart/todoapp
git add bootstrap.sh
git add INSTRUCTION.md
git add output.log
```

Перевір staging:

```bash
git diff --cached
git status
```

Створи commit і відправ поточну гілку:

```bash
git commit -m "Create Helm charts for todoapp and MySQL"
git push -u origin "$(git branch --show-current)"
```

У Pull Request перевір, що присутні parent chart, `charts/mysql`,
`bootstrap.sh`, `INSTRUCTION.md` та `output.log`.
