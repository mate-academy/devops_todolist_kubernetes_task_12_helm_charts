
set -e

echo "Creating KIND cluster..."

kind create cluster --config .infrastructure/cluster.yml

echo "Checking nodes..."

kubectl get nodes --show-labels

echo "Tainting mysql nodes..."

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "Updating helm dependencies..."

helm dependency update .infrastructure/helm-chart/todoapp

echo "Installing todoapp helm chart..."

helm install todoapp .infrastructure/helm-chart/todoapp

echo "Deployment completed"