## Run Todoapp

### Automated Deployment (Recommended)

Run the bootstrap script to create the Kind cluster, verify node labels, apply taints for MySQL node dedicated scheduling, and deploy the Helm chart:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```



## Install helm chart
```
helm install todoapp-release .infrastructure/helm-chart/todoapp
```

## Validate helm chart
```
helm install todoapp-release .infrastructure/helm-chart/todoapp --dry-run
```

## Unistall helm chart
```
helm uninstall todoapp-release
```