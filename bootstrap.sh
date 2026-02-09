kind create cluster --config cluster.yml

kubectl wait --for=condition=Ready nodes --all --timeout=120s

cd .infrastructure/helm-chart/todoapp
helm dependency update

kubectl get nodes -l app=mysql -o name | xargs -r kubectl taint nodes app=mysql:NoSchedule --overwrite

helm install todoapp . --create-namespace

# Wait for deployments to be ready
echo "Waiting for deployments to settle..."
kubectl wait --for=condition=available --timeout=300s deployment/todoapp -n todoapp 2>/dev/null || true

# Generate output log with all resources
cd ../../../
kubectl get all,cm,secret,ing -A > output.log
