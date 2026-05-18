#!/bin/bash
kind delete cluster --name kind
kind create cluster --config ./cluster.yml
helm install todoapp .infrastructure/helm-charts/todoapp/
