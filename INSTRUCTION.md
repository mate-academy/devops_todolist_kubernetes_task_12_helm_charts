# Validation

## Prerequisites

Install Docker, kind, kubectl, and Helm. Run commands below from the repository root.
The bootstrap script creates a kind cluster, installs the ingress controller, and installs
the todoapp chart. Use a fresh cluster because it creates the cluster by name.

## Validate and deploy


Deploy the cluster and chart:

```sh
bash ./bootstrap.sh
```

Wait for MySQL and the application rollout to complete:

```sh
kubectl rollout status statefulset/mysql -n mysql
kubectl rollout status deployment/todoapp-release-todoapp -n todoapp
```

## Verify

Confirm the nodes have the expected labels and MySQL taints:

```sh
kubectl get nodes --show-labels
kubectl describe nodes
```

Check that MySQL and todoapp pods are Ready, services have endpoints, and the
todoapp PVC is Bound:

```sh
kubectl get pods,services,endpoints,pvc -n mysql
kubectl get pods,services,endpoints,pvc -n todoapp
kubectl get hpa -n todoapp
```

Open `http://localhost/` and confirm the landing page loads. The health endpoint
should return HTTP 200 at `http://localhost/api/health`.

Save the required cluster resource inventory to the repository root:

```sh
kubectl get all,cm,secret,ing -A > output.log
```

If a pod is not Ready, inspect its events and logs with `kubectl describe pod`
and `kubectl logs` in the relevant namespace.