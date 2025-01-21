# Instructions to Verify Changes

1. **Run the Bootstrap Script**  
   To deploy everything in the cluster (including the necessary prerequisites and the application), simply run the `bootstrap.sh` script:
   ```bash
   chmod +x ./bootstrap.sh
   ./bootstrap.sh
   ```

2. **Check Cluster Resources**  
   After running the script, verify the status of all resources in your Kubernetes cluster by running:
   ```bash
   kubectl get all,cm,secret,ing -A
   ```
   This will display all the pods, services, secrets, and ingress resources across all namespaces.

3. **Save the Output**  
   Save the output from the previous command into a file called `output.log` in the root directory of your project.

4. **Verify the Deployment**  
   - Ensure that the application is deployed and running correctly.
   - Check if all the required services, deployments, and pods are created and are in a healthy state.

5. **Test the Application**  
   - Access the application either through the NodePort or via an Ingress route.
   - Test the basic functionality to confirm that the app works as expected.

6. **Check Scaling**  
   Ensure that the Horizontal Pod Autoscaler is working correctly by checking if the application scales based on CPU or memory usage.
