1. port-forward ClusterIP of todoapp:
```angular2html
    kubectl port-forward todoapp/todoapp-service 8081:80
```
2. On localmachine try http get request in one of browser:
    http://localhost:8081