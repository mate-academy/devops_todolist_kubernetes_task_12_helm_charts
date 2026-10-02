# Validation Instructions

## 1. Deploy the project

Make sure Docker is running.

Run the bootstrap script from the root of the repository:

```bash
bash bootstrap.sh
```

The script will:
- create a Kubernetes cluster using kind;
- add the required taints to MySQL nodes;
- install the NGINX Ingress Controller;
- update Helm dependencies;
- install the `todoapp` Helm chart with the MySQL subchart.

## 2. Check Kubernetes resources

Check that all required resources were created:

```bash
kubectl get all,cm,secret,ing -A
```

## 3. Check the Helm release

```bash
helm list -A
```

The `todoapp` release should have the `deployed` status.

## 4. Check Pods

```bash
kubectl get pods -A
```

The `todoapp`, `mysql`, and `ingress-nginx` Pods should be in the `Running` state.

## 5. Check the application

Run:

```bash
curl http://localhost
```

The command should return the Todo application HTML.

The application can also be opened in a browser at:

`http://localhost`