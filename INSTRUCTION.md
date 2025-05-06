# What Needs to Be Done to Validate the Deployment
1. ## Verify Helm Releases Are Installed
- Run `helm list -A`
- Confirm that both `todoapp` and `mysql` charts are deployed
2. ## Check All Kubernetes Resources
- Run `kubectl get all,cm,secret,ing -A`
- Ensure all necessary resources (pods, services, secrets, configmaps) exist