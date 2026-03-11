
# ToDo Application Deployment (Helm & Kubernetes)

This repository contains a full-stack deployment of a ToDo application with a MySQL database sub-chart, automated for a **Kind** (Kubernetes in Docker) environment.

## 📋 Prerequisites

Before running the deployment script, ensure you have the following tools installed:
- **Docker**
- **Kind**
- **kubectl**
- **Helm** (v3+)

---

## 🚀 Quick Start (Automated Deployment)

To spin up the cluster, configure nodes, and deploy the application with all its components, run the bootstrap script from the root directory:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will:

1. Create a Kind cluster using `cluster.yml`.
2. Apply specific **Taints** to nodes labeled `app=mysql`.
3. Build/Update Helm dependencies (packaging the **MySQL sub-chart**).
4. Deploy the `todoapp` Helm chart into the `todoapp` namespace.
---

## ✅ Validation Checklist

You can verify the requirements using the following commands:

### 1. Nodes, Labels, and Taints

Verify that nodes are correctly labeled and tainted:

```bash
kubectl describe nodes -l app=mysql | grep Taints
```

*Expected output:* `Taints: app=mysql:NoSchedule`

### 2. Helm Chart & Sub-chart Dependencies

Check the Helm release and ensure the sub-chart is integrated:

```bash
helm list -n todoapp
ls ./helm-chart/todoapp/charts/
```

### 3. Application Resources

Verify that all resources (Deployments, StatefulSets, HPA, Services) are running:

```bash
kubectl get all -n todoapp
```

### 4. Storage (PV & PVC)

Check if the PersistentVolumes and Claims are correctly bound:

```bash
kubectl get pv,pvc -n todoapp
```

### 5. Horizontal Pod Autoscaler (HPA)

Verify HPA is managing the ToDo app replicas based on CPU/Memory:

```bash
kubectl get hpa -n todoapp
```

### 6. Role-Based Access Control (RBAC)

Check the ServiceAccount and RoleBindings:

```bash
kubectl get sa,role,rolebinding -n todoapp
```

---

## 🌐 Accessing the Application

If you are using the provided **Ingress** configuration on Kind:

1. Ensure the Ingress controller is installed and ready.
2. Access the application at: `http://localhost`

Alternatively, you can use port-forwarding:

```bash
kubectl port-forward svc/todoapp-service 8080:80 -n todoapp
```

Then visit `http://localhost:8080`.

---

