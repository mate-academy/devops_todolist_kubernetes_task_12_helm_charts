# Deployment Guide
1. **Create cluster**
    ```sh
    kind create cluster --config cluster.yml
    ```

2. **Apply all manifests**
    ```sh
    ./bootstrap.sh
    ```

## Verification

1. **Check pods**
    ```sh
    kubectl get pods -n todoapp
    kubectl get pods -n mysql
    ```

2. **Check tained nodes**
    ```sh
    kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
    ```

3. **Check logs**
    ```sh
    kubectl logs <name_of_pod> -n <namespace>
    ```

4. **Check browser**
    ```sh
    http://localhost/ or http://localhost/30007
    ```

5. **Check helm history**
    ```sh
    helm history
    ```