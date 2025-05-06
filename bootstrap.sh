#!/bin/bash

if [ -d todoapp ]; then
  echo "Installing Helm chart from todoapp directory..."
  helm install todoapp-release .infrastructure/helm-chart/todoapp
fi