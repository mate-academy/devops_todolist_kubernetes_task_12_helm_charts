# Django ToDo list

This is a to-do list web application with the basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

- CSS | [Skeleton](http://getskeleton.com/)
- JS  | [jQuery](https://jquery.com/)

## Explore

First of all, run the following command to create the cluster:
```
kind create cluster --config cluster.yml
```

Taint nodes:
```
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Install the Ingress to your cluster:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Navigate to .infrastructure folder:
```
cd .infrastructure
```

And verify the Helm templates by:
```
helm install todoapp helm-chart/todoapp --dry-run
```

Install the helm cluster:
```
helm install todoapp helm-chart/todoapp
```

Get the info about the status:
```
kubectl get all,cm,secret,ing -A
```

After starting the application you will be able to access the app on http://localhost/

If the page loads and active - congrats! You've done it well!
