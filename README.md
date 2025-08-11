**Helm-Based Kubernetes Deployment with Kind**

📌 Project Overview
This project demonstrates a complete Helm-based Kubernetes deployment of a Django-based ToDo application with a MySQL backend, configured for use with a local kind cluster.
It showcases advanced Helm templating techniques, chart dependencies, resource customization, and controlled deployments through values.yaml.

**🛠 Tech Stack**
    - Kubernetes (kind) – Local Kubernetes cluster setup

    - Helm – Kubernetes package manager

    - Helm Subcharts – todoapp and dependent mysql

    - MySQL – Persistent database (as a Helm subchart)

    - Bash – Shell scripting for automated bootstrap

**🚀 What Was Done**
1️⃣ Cluster and Nodes
    - Created a local kind cluster using cluster.yml.

    - Inspected nodes for labels and taints.

    - Applied a taint app=mysql:NoSchedule to restrict scheduling of MySQL pods to specific nodes.

2️⃣ Helm Chart Structure
    - Created a Helm chart todoapp inside the helm-chart/ directory.

    - Added a Helm subchart mysql inside helm-chart/todoapp/charts/.

3️⃣ Todoapp Chart Features
    - All Kubernetes resource names prefixed with .Chart.Name.

    - Configurable via values.yaml:

        - Namespace

        - Image

        - Secrets
        
        - Resources
        
        - Volumes
        
        - HPA
        
        - Affinity rules
        
    - Secrets dynamically generated using range and injected as environment variables.
    
    - RollingUpdate strategy with custom resource requests/limits.
    
    - HPA for CPU/Memory autoscaling with customizable thresholds.
    
    - Affinity rules to schedule pods on specific nodes.

4️⃣ MySQL Subchart Features
    - StatefulSet with Persistent Volume Claim.
    
    - Tolerations and node affinity configurable via values.yaml.
    
    - Secrets generation using range for secure DB credentials.
    
    - Configurable resource requests, PVC size, and replica count.

5️⃣ Documentation
Created INSTRUCTION.md with detailed steps for running the Helm-Based Kubernetes Deployment with kind.
