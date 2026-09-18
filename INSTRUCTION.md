### Run the deployment script:

```bash
./bootstrap.sh
```

### Validate Pods & Services Status

```bash
kubectl get pods,svc -n todoapp -o wide
```

```bash
kubectl get all,cm,secret,ing -A > output.log
```