# Validation Guide

1. Ensure tools are installed: `kind`, `kubectl`, `helm`, and `docker`.
2. From repository root, run:
   ```bash
   ./bootstrap.sh
   ```
3. Confirm output file exists:
   ```bash
   ls -l output.log
   ```
4. Validate chart rendering and lint:
   ```bash
   helm lint .infrastructure/helm-chart/todoapp
   helm template .infrastructure/helm-chart/todoapp -f .infrastructure/helm-chart/todoapp/values.yaml
   ```
5. Verify expected resources are present in `output.log`:
   - `mysql` pods with prefix `mysql-` in `Running` state.
   - `todoapp` pods with prefix `todoapp` in `Running` state.
   - `horizontalpodautoscaler.autoscaling/todoapp`.
   - `ingress.networking.k8s.io/todoapp-ingress`.
