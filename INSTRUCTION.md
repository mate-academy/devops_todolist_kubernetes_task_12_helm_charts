To validate changes use commands:

    To install helm release use command:

        helm install todoapp ./charts/todoapp

Then use commands:

    To check app pods:

        kubectl get pods -n todoapp     ### Remember at least name of one pod


    To check mysql pods:

        kubectl get pods -n mysql

Then make port-forward using command:

    kubectl port-forward pod/<pod_name> 8080:8080

The go to localhost:8080 in your browser