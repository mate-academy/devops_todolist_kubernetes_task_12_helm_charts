Run scripts
./bootstrap.sh
2. After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
3. Inspect labels and taints:
Check labels, use command
kubectl get nodes --show-labels
If labels app=mysql and   not exists, use commands:
kubectl label nodes kind-worker kind-worker2 app=mysql
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp