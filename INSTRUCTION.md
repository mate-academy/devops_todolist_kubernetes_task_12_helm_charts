# Validation

## Deploy

```bash
./bootstrap.sh
```

## Check nodes, labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "Name:|Taints:"
```

Nodes labeled `app=mysql` must have the taint `app=mysql:NoSchedule`.

## Check the release

```bash
helm list -A
helm get values todoapp --all
```

## Check resources

```bash
kubectl get all,cm,secret,ing -A
kubectl get pv,pvc -A
kubectl get sa,role,rolebinding -n todoapp
```

MySQL pods must run only on `app=mysql` nodes, todoapp pods only on `app=todoapp` nodes:

```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
```

## Check secrets as env variables

```bash
kubectl exec -n todoapp deploy/todoapp-deployment -- env | grep DB_
```

## Check the application

Open http://localhost/ in a browser or run:

```bash
curl http://localhost/
```

## Check values control

Change any value (for example `hpa.maxReplicas`) and apply:

```bash
helm upgrade todoapp ./.infrastructure/helm-chart/todoapp --set hpa.maxReplicas=7
kubectl get hpa -n todoapp
```
