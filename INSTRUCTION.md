# Validation Instructions

1. Run `./bootstrap.sh`.
2. Verify the `kind` cluster exists with `kind get clusters`.
3. Check node labels with `kubectl get nodes -L app`.
4. Check mysql taints with `kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints`.
5. Confirm Helm releases with `helm list -A`.
6. Confirm the application namespace resources with `kubectl get all -n todoapp`.
7. Confirm the MySQL namespace resources with `kubectl get all -n mysql`.
8. Confirm persistent storage with `kubectl get pv,pvc -A`.
9. Confirm autoscaling is present with `kubectl get hpa -n todoapp`.
10. Confirm RBAC objects were created with `kubectl get sa,role,rolebinding -n todoapp`.
11. Confirm the captured cluster state exists in `output.log`.
12. Open `http://localhost:30017/` after the ingress controller finishes starting.
