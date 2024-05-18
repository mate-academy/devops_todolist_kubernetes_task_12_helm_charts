
# Kubernetes Manifest for Todoapp

This repository contains the Kubernetes manifests for deploying a ToDo app using Helm. Below are the instructions for setting up the environment and deploying the application.

## Instructions

### Environment Setup

Install Kind: Use kind to spin up a Kubernetes cluster. You can find the configuration file cluster.yml within the repository. Use it to create a cluster with the necessary specifications.

```bash
kind create cluster --config=cluster.yml
```

### Helm Chart install

```bash
./bootstrap.sh
```

### Check active namespaces

```bash
kubectl get ns
```

### Check helm list

```bash
helm list
```

### Check helm release history

```bash
helm history todoapp
```

### Command delete release

```bash
helm uninstall todoapp
```
