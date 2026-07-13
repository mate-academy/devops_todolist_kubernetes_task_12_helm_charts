# Instructions

## Deploy

```bash
bash bootstrap.sh
```

## Validate

### 1. Nodes labels and taints
```bash
kubectl describe nodes | grep -E "Name:|Labels:|Taints:"
```
Expected: ноды с `app=mysql` имеют тайнт `app=mysql:NoSchedule`

### 2. All resources deployed
```bash
kubectl get all,cm,secret,ing -A
```

### 3. Todoapp pods running
```bash
kubectl get pods -n todoapp
```
Expected: STATUS `Running`, READY `1/1`

### 4. MySQL pods running on mysql nodes
```bash
kubectl get pods -n mysql -o wide
```
Expected: каждый под на отдельной ноде с лейблом `app=mysql`

### 5. App accessible
Открой в браузере: http://localhost

### 6. Helm release status
```bash
helm list -A
```
Expected: статус `deployed`

### 7. Standalone Pod running

```bash
kubectl get pod todoapp-pod -n todoapp -o wide
```
Expected: STATUS `Running`, запущен на ноде с лейблом `app=todoapp`