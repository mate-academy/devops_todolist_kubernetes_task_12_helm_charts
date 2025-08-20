1.	Ensure you are connected to the Kubernetes cluster where you want to deploy the charts. Use kubectl config get-contexts to verify the current context.
	2.	Navigate to the root directory of your todoapp Helm chart.
	3.	Check that all required values are correctly set in values.yaml for both todoapp and mysql sub-chart. Verify namespace names, secrets, resource requests and limits, rolling update parameters, affinity, HPA settings, PV and PVC sizes, image repositories and tags.
	4.	Verify that the Chart.yaml file in todoapp includes the dependency on the mysql chart:
	•	There should be a section dependencies: with an entry - name: mysql.
	5.	Package the charts to ensure the dependencies are recognized. Run:
helm dependency update todoapp
	6.	Install or upgrade the todoapp release in the cluster using the specified namespace from values.yaml:
helm upgrade –install todoapp ./helm-chart/todoapp
	7.	Validate that the namespace is created and active:
kubectl get ns
	8.	Validate that all todoapp resources are created with names prefixed by .Chart.Name:
kubectl get all -n 
	9.	Verify that secrets are created in the correct namespace and contain the expected keys and values:
kubectl get secret -n  -o yaml
	10.	Verify that the todoapp deployment contains the environment variables mapped from secrets using the range function:
kubectl describe deployment todoapp -n  | grep -A5 Env
	11.	Verify that resource requests and limits, rolling update parameters, and node affinity are correctly applied:
kubectl describe deployment todoapp -n 
	12.	Verify that the HPA is created with the correct min/max replicas and target CPU and memory utilization:
kubectl get hpa -n 
kubectl describe hpa todoapp -n 
	13.	Verify that persistent volumes and persistent volume claims are created with correct capacities and access modes:
kubectl get pv
kubectl get pvc -n 
	14.	Verify that the Service Account is created and attached to the deployment and RBAC objects:
kubectl get sa -n 
kubectl describe deployment todoapp -n  | grep ServiceAccount
	15.	Verify that the mysql sub-chart is deployed with the correct number of replicas in its StatefulSet, secrets, image repository and tag, PVC requests, affinity and tolerations, and resource limits:
kubectl get statefulset -n 
kubectl describe statefulset mysql -n 
kubectl get secret -n  -o yaml
	16.	Verify that todoapp pods are running and ready:
kubectl get pods -n 
	17.	Access the application locally to validate it is reachable:
kubectl port-forward -n  deployment/todoapp 8080:8080
Open a browser and navigate to http://localhost:8080