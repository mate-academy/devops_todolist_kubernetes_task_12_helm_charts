#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}===> Creating cluster using Kind...${NC}"
kind create cluster --config cluster.yml --wait 5m

echo -e "${GREEN}===> Setting up Taints for nodes...${NC}"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo -e "${GREEN}===> Upgrading dependencies Helm (sub-charts)...${NC}"
helm dependency update .infrastructure/helm-chart/todoapp

echo -e "${GREEN}===> Deploying todoapp together with mysql...${NC}"
helm upgrade --install todoapp-release .infrastructure/helm-chart/todoapp \
  --namespace todoapp \
  --create-namespace \
  --wait

echo -e "${GREEN}===> Ready to use!${NC}"