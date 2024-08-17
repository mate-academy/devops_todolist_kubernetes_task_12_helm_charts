#!/bin/bash
kind create cluster --config cluster.yml

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm install todoapp .infrastructure/helm-chart/todoapp
