# Validation Instructions

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [helm](https://helm.sh/docs/intro/install/) installed

## Steps

1. Create a kind cluster:
   ```bash
   kind create cluster --config cluster.yml
   ```

2. Taint nodes labeled with `app=mysql`:
   ```bash
   kubectl taint nodes $(kubectl get nodes -l app=mysql -o name) app=mysql:NoSchedule
   ```

3. Run the bootstrap script:
   ```bash
   bash bootstrap.sh
   ```

4. Wait for all pods to reach Running state:
   ```bash
   kubectl get pods -A -w
   ```

5. Verify the deployment:
   ```bash
   kubectl get all,cm,secret,ing -A
   ```

6. Access the application via the NodePort:
   ```
   http://localhost:30007
   ```

## Validation

- `mysql` namespace should have 2 running pods (`mysql-0`, `mysql-1`)
- `todoapp` namespace should have 2 running pods
- HPA `todoapp` should be present in `todoapp` namespace
- Ingress `todoapp-ingress` should be present in `todoapp` namespace
