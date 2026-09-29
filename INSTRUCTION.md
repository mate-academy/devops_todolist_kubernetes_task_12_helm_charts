# Django ToDo List — Kubernetes & Helm Deployment

## Project Overview
Welcome to the Django ToDo List deployment project. This repository houses a fully functional ToDo web application built with Django, featuring user authentication, an interactive UI (HTML/Skeleton CSS/jQuery), and a REST API. 

The primary objective of this repository is to demonstrate advanced Kubernetes orchestration and Helm templating. It automates the deployment of the Django application and its MySQL database dependency into a local `kind` cluster.

## Architecture & DevOps Highlights
This project utilizes a two-tier architecture deployed via a custom Helm chart (`todoapp`) and a linked sub-chart (`mysql`). Key infrastructure features include:

* **Automated Helm Orchestration:** All resources are dynamically generated using Helm templates, with variables, prefixes (`.Chart.Name`), and secrets strictly controlled via `values.yaml`.
* **Advanced Pod Scheduling:** Utilizes Taints, Tolerations, and Node Affinity to ensure specific workloads (like MySQL) are scheduled on dedicated nodes.
* **Dynamic Secret Management:** Uses Helm `range` functions to iterate through and inject secure data as environment variables.
* **Auto-Scaling & Resource Management:** Implements Horizontal Pod Autoscaler (HPA) configurations and strictly defines CPU/Memory requests and limits.
* **Persistent Storage:** Configures PersistentVolumes (PV) and PersistentVolumeClaims (PVC) to guarantee database state persistence.
* **One-Click Deployment:** A `bootstrap.sh` script handles all prerequisite setup and fully deploys the Helm charts to the cluster.

---