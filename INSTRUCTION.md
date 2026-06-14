# 1) How to validate the changes:

**Create cluster:**

    kind create cluster --config cluster.yml
    kubectl get nodes -o wide 

**Taint nodes with labels *app=mysql*:**

    kubectl taint nodes -l app=mysql app=mysql:NoSchedule


**Install dependency:**
     
    helm dependency update ./.infrastructure/helm-chart/todoapp

**Install release:**

    helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp

**Check the changes:**

    kubectl get all,cm,secret,ing -A > output.log 
