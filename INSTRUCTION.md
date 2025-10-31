## Validate helm release for Todoapp.

1. Execute bootstrap.sh to deploy todoapp helm chart:

    ./bootstrap.sh

### 2. Check if cluster and namespace created:

    kubectl cluster-info

Expected output like: "Kubernetes control plane is running at https://..."

    kubectl get ns | grep -E 'mysql|todoapp'

Expected non-empty output.

### 3. Check chart resources:

    helm upgrade --install todoapp-release ./helm-chart/todoapp -n todoapp --dry-run
