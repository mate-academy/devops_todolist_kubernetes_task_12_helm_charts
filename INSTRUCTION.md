1. port-forward ClusterIP of todoapp:
```angular2html
    kubectl port-forward todoapp/todoapp-service 8081:80
```
2. On localmachine try http get request in one of browser:
    http://localhost:8081
3. To inspect nodes and taints:
```angular2html
kubectl describe nodes
kubectl get nodes --show-labels
kubectl taint nodes <node-name> app=mysql:NoSchedule
```
4. To validate output.log you can run following commands and compare output with output in log:
```angular2html
kubectl get pods -n todoapp
kubectl get pods -n mysql
kubectl get svc -n todoapp
```
5. To validate correct working of pods must be Desired, Current and Running number of pods be equal 
```angular2html
kubectl get all,cm,secret,ing -A
```
And check proper work of app in browser.