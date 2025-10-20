### 1. Create the cluster from config file, taint first and second nodes and run helm installation:
```bash
./bootstap.sh
```

### 2. Validate deployment, statefulSet and other configs by the command below:
```bash
kubectl get all,cm,secret,ing -A >> output.log
```
You need to check that each pod is healthy and running in the output.log
