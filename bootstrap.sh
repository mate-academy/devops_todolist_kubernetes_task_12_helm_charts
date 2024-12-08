#!/bin/bash

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm install todoapp-release .infrastructure/helm-chart/todoapp
