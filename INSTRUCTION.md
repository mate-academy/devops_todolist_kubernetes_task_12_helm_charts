### Run script to deploy project:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```
### Fetch information about all Kubernetes resources 
```bash
kubectl get all,cm,secret,ing -A
```