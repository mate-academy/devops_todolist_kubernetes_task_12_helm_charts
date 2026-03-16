# Validation Instructions

1. Make sure `docker`, `kind`, `kubectl`, and `helm` are installed.
2. From the repository root, run:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

If ports `80` or `443` are busy on your machine, run with different host ports:

```bash
HOST_HTTP_PORT=8080 HOST_HTTPS_PORT=8443 ./bootstrap.sh
```

If the NodePort mappings are also busy, override them too:

```bash
HOST_NODEPORT_APP=31007 HOST_NODEPORT_EXTRA=31008 HOST_HTTP_PORT=18080 HOST_HTTPS_PORT=18443 ./bootstrap.sh
```

3. Verify that the Helm chart renders correctly:

```bash
helm lint .infrastructure/helm-chart/todoapp
helm template todoapp .infrastructure/helm-chart/todoapp -f .infrastructure/helm-chart/todoapp/values.yaml
```

4. Verify that the cluster resources were deployed:

```bash
kubectl get all,cm,secret,ing -A
cat output.log
```

5. Confirm the expected resources exist:
   - namespace `todoapp`
   - namespace `mysql`
   - `todoapp` deployment and HPA
   - `mysql` StatefulSet and headless service
   - generated secrets/configmaps from both charts
