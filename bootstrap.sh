#!/bin/bash
NODES=("kind-worker" "kind-worker2")
kind create cluster --config ./cluster.yml

for NODE in "${NODES[@]}"; do
    if kubectl get nodes | grep -q "$NODE"; then
        echo "<<<>>> NODE '$NODE' was found. <<<>>>"
        kubectl label nodes "$NODE" app=mysql --overwrite
        kubectl taint nodes "$NODE" app=mysql:NoSchedule --overwrite
    else
        echo "NODE '$NODE' was not found."
        exit
    fi
done

helm dependency build .infrastructure/helm-chart/todoapp/
helm install todoapp .infrastructure/helm-chart/todoapp
#kubectl get pods -A -o wide
#helm list
#helm dependency list ./helm-chart/todoapp/
