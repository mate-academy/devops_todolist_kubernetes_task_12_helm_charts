### Install Kind: Use kind to spin up a Kubernetes cluster. You can find the configuration file cluster.yml within the repository. Use it to create a cluster with the necessary specifications.

```bash
kind create cluster --config=cluster.yml
```

### Preview of all manifests in the Helm chart

Before installing the `todoapp` Helm chart, you can preview all the manifests it will generate by running:

```bash
helm install todoapp helm-chart/todoapp --dry-run
```

### Install todoapp Helm chart

```bash
./bootstrap.sh
```

or

```bash
helm install todoapp helm-chart/todoapp
```

### Check the status of pods

```bash
kubectl get pods -n todoapp -o wide
```

### Check Helm release history

```bash
helm history todoapp
```

### Upgrade the Helm chart

```bash
helm upgrade todoapp helm-chart/todoapp
```
