# Verification Instructions — todoapp Helm Chart

This document describes how to verify the correct deployment of the `todoapp` application
along with the `mysql` database in the `kind` Kubernetes cluster using Helm.

## Prerequisites

Before verification, the following must be installed:
- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3](https://helm.sh/docs/intro/install/)

## 1. Deploy the cluster and application

All steps are automated in `bootstrap.sh`. Run from the root of the repository:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will do the following:
1. Create a kind cluster from the `cluster.yml` configuration (1 control-plane + 5 worker nodes).
2. Taint nodes with the `app=mysql` label with the `app=mysql:NoSchedule` taint.
3. Install NGINX Ingress Controller.
4. Update Helm dependencies (`helm dependency update`).
5. Install the `todoapp` chart (along with the `mysql` subchart) in the `todoapp` namespace.

## 2. Check nodes: labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep -A5 Taints
```

Expected:
- 2 nodes with label `app=mysql` have taint `app=mysql:NoSchedule`.
- Nodes with label `app=todoapp` have no taints.

## 3. Check Helm release status

```bash
helm list -n todoapp
helm status todoapp -n todoapp
```

Expected release status `deployed`.

## 4. Check cluster resources

```bash
kubectl get all,cm,secret,ing -A
```

Expected:
- Namespace `todoapp` contains: Deployment, Service (ClusterIP + NodePort), HPA, PVC, ConfigMap, Secret, ServiceAccount.
- Namespace `mysql` contains: StatefulSet (2 replicas), Service (headless), ConfigMap, Secret.
- Ingress `todoapp-ingress` is present in namespace `todoapp`.

Compare the result with the `output.log` file in the root of the repository — the reference output of this command is saved there.

## 5. Checking pods

```bash
kubectl get pods -n todoapp -o wide
kubectl get pods -n mysql -o wide
```

Expected:
- All pods are in `Running` status.
- `mysql` pods are located exclusively on nodes with the label `app=mysql` (affinity + toleration worked correctly).
- `todoapp` pod does not reach mysql nodes (due to taint).

## 6. Test the application via Ingress

```bash
curl -H "Host: localhost" http://localhost/api/health
```

Expect a successful response (HTTP 200) from the `livenessProbe` endpoint.

Alternatively, test via NodePort:
```bash
curl http://localhost:30080/api/health
```

## 7. Test Auto Scaling (HPA)

```bash
kubectl get hpa -n todoapp
kubectl describe hpa -n todoapp
```

HPA is expected to monitor CPU/Memory utilization according to the values ​​in `values.yaml`
(`targetCPUUtilizationPercentage`, `targetMemoryUtilizationPercentage`).

## 8. Check Secrets and ConfigMaps

```bash
kubectl get secret -n todoapp -o yaml
kubectl get configmap -n todoapp -o yaml
kubectl get secret -n mysql -o yaml
```

Secret values ​​must be base64 encoded (generated automatically via the Helm function `b64enc` from the exposed values ​​in `values.yaml`).

## 9. Check todoapp → mysql dependency

```bash
helm dependency list helm-chart/todoapp
```

Expected `mysql` to be listed as a dependency with status `ok`.

## 10. Clean up the environment (if needed)

```bash
helm uninstall todoapp -n todoapp
kind delete cluster --name todoapp-cluster
```

## Repository structure

```
helm-chart/todoapp/
├── Chart.yaml # main chart, dependencies -> mysql
├── values.yaml # todoapp parameters
├── templates/ # todoapp manifests
└── charts/mysql/ # mysql sub-chart
├── Chart.yaml
├── values.yaml
└── templates/ # mysql manifests
```