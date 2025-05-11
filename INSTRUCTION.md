# ✅ Instructions to Validate the ToDoApp Helm Chart Deployment

## Prerequisites

- Docker + kind installed on your local machine
- kubectl installed and configured
- Helm installed

## 1️⃣ Create a kind cluster

If you don't have a cluster yet, create it using your cluster configuration file:

```bash
kind create cluster --config cluster.yml
```

## Check that your cluster is running
```
kubectl cluster-info
```

## run app
```
chmod +x bootstrap.sh
./bootstrap.sh
```

## list all resources

```
kubectl get all -n todoapp
```

## Check logs of your application pod

```
kubectl get pods -n todoapp
kubectl logs <your-app-pod-name> -n todoapp
```

## Save all resources to output.log

After successful deployment, run:

```
kubectl get all,cm,secret,ing -A > .infrastructure/helm-chart/output.log

```