# How to validate the changes

1. Start Docker, then run `bash bootstrap.sh`. It creates the `kind` cluster from `cluster.yml`, taints the `app=mysql` nodes, installs ingress-nginx and metrics-server, installs the `todoapp` helm chart (with the `mysql` sub-chart) and writes `output.log`.
2. Check the nodes: `kubectl get nodes --show-labels` and `kubectl describe nodes | grep Taints`. The two `app=mysql` workers must have the `app=mysql:NoSchedule` taint.
3. Check the chart: `helm lint helm-chart/todoapp` and `helm template helm-chart/todoapp`.
4. Check the workloads: `kubectl get all,cm,secret,ing -A`. The `mysql-mysql` namespace needs 2 running `mysql-statefulset-*` pods. The `todoapp-todoapp` namespace needs 2 or more running `todoapp-*` pods, the `todoapp` HPA and the `todoapp-ingress` ingress.
5. Open http://localhost/ in a browser to see the app.
6. To check that values drive the chart, run `helm template helm-chart/todoapp --set namespace=test --set hpa.maxReplicas=8`.
