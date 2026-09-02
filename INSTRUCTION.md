# TodoApp Helm Charts

## Prerequisites

The following tools are required:

* Docker
* kind
* kubectl
* Helm

Verify the installation:

```bash
docker --version
kind version
kubectl version --client
helm version
```

## 1. Create the kind cluster

Create the Kubernetes cluster using `cluster.yml`:

```bash
kind create cluster --name todoapp --config cluster.yml
```

Verify the nodes and their labels:

```bash
kubectl get nodes --show-labels
```

The cluster contains nodes labeled with:

```text
app=mysql
app=todoapp
```

## 2. Inspect node labels and taints

Display node taints:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Apply the required taint to all nodes labeled `app=mysql`:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Verify the taint:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

MySQL nodes must have:

```text
app=mysql:NoSchedule
```

## 3. Helm chart structure

The main Helm chart is located at:

```text
helm-chart/todoapp
```

The MySQL subchart is located at:

```text
helm-chart/todoapp/charts/mysql
```

The main chart declares MySQL as an explicit dependency in `Chart.yaml`:

```yaml
dependencies:
  - name: mysql
    version: 0.1.0
    repository: "file://charts/mysql"
```

Build the dependency:

```bash
helm dependency build helm-chart/todoapp
```

## 4. Validate the Helm chart

Run Helm lint:

```bash
helm lint helm-chart/todoapp
```

The expected result is:

```text
1 chart(s) linted, 0 chart(s) failed
```

Render the templates to verify the generated Kubernetes manifests:

```bash
helm template todoapp helm-chart/todoapp --namespace todoapp
```

## 5. Deploy the TodoApp Helm chart

Create the namespace if it does not already exist:

```bash
kubectl create namespace todoapp
```

If the namespace already exists, continue with the next step.

Install the Helm release:

```bash
helm upgrade --install todoapp helm-chart/todoapp \
  --namespace todoapp
```

Verify the release:

```bash
helm list -n todoapp
```

The release status must be:

```text
deployed
```

## 6. Verify the application

Check all application resources:

```bash
kubectl get all -n todoapp
```

Check Pods and their nodes:

```bash
kubectl get pods -n todoapp -o wide
```

TodoApp Pods must be scheduled on nodes labeled:

```text
app=todoapp
```

MySQL must be scheduled on a node labeled:

```text
app=mysql
```

The MySQL Pod can run on the tainted MySQL nodes because the MySQL subchart defines the required toleration.

## 7. Verify Persistent Volumes

Check PersistentVolumes:

```bash
kubectl get pv
```

Check PersistentVolumeClaims:

```bash
kubectl get pvc -n todoapp
```

The application and MySQL PVCs must have the status:

```text
Bound
```

## 8. Verify HPA

Check the HorizontalPodAutoscaler:

```bash
kubectl get hpa -n todoapp
```

The TodoApp HPA is configured using values from `values.yaml`:

* Minimum replicas: `2`
* Maximum replicas: `5`
* CPU average utilization: `70%`
* Memory average utilization: `80%`

If CPU or memory is displayed as `<unknown>`, Metrics Server is not available in the kind cluster. The HPA resource itself is still created correctly.

## 9. Verify ServiceAccount and RBAC

Check the ServiceAccount:

```bash
kubectl get serviceaccount -n todoapp
```

Check the Role:

```bash
kubectl get role -n todoapp
```

Check the RoleBinding:

```bash
kubectl get rolebinding -n todoapp
```

Verify that the Deployment uses the configured ServiceAccount:

```bash
kubectl get deployment todoapp-deployment -n todoapp \
  -o jsonpath='{.spec.template.spec.serviceAccountName}'
```

The expected result is:

```text
todoapp
```

## 10. Verify Secrets

Check the created Secrets:

```bash
kubectl get secret -n todoapp
```

The chart creates:

```text
todoapp-secret
mysql-secret
```

Secret values are configured through `values.yaml` and encoded using Base64 in the generated Kubernetes Secret manifests.

## 11. Generate output.log

Generate the required cluster information from the root directory of the repository:

```bash
kubectl get all,cm,secret,ing -A > output.log
```

Verify the file:

```bash
cat output.log
```

The file must be located in the repository root.

## 12. Bootstrap script

The repository contains `bootstrap.sh` with the commands required to prepare the cluster and deploy the TodoApp Helm chart.

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run it on a clean environment:

```bash
./bootstrap.sh
```

The script performs the required cluster creation, MySQL node tainting, Helm chart validation, dependency build, deployment, and `output.log` generation.

## 13. Final verification

Before committing the changes, run:

```bash
kubectl get nodes --show-labels
```

```bash
kubectl get pods -n todoapp -o wide
```

```bash
kubectl get pv
```

```bash
kubectl get pvc -n todoapp
```

```bash
kubectl get hpa -n todoapp
```

```bash
kubectl get serviceaccount,role,rolebinding -n todoapp
```

```bash
helm list -n todoapp
```

```bash
helm lint helm-chart/todoapp
```

```bash
git status
```

## 14. Commit and push

Add the changes:

```bash
git add .
```

Create a commit:

```bash
git commit -m "Add Helm charts for todoapp and mysql"
```

Push the `helm-charts` branch:

```bash
git push -u origin helm-charts
```

Create a Pull Request from `helm-charts` to `main` for validation.
