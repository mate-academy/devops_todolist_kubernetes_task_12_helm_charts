#!/usr/bin/env bash
set -e

kind create cluster --config cluster.yml

kubectl get nodes -o wide

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm install todoapp-release ./todoapp