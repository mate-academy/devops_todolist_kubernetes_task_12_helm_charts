# How to validate the Helm chart and Kubernetes setup

Follow these steps to validate your implementation according to the requirements:

## 1. Prepare your environment

- Ensure you have Docker and kind installed.
- Clone your forked repository and navigate to the project root.

## 2. Inspect node labels and taints

- List nodes and check their labels:

```sh
kubectl get nodes --show-labels
```
- Check taints:
```sh
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```


## 3. Deploy prerequisites and Helm chart

Run the [bootstrap.sh](./bootstrap.sh) script to deploy all prerequisites and the Helm chart:
```sh
bash bootstrap.sh
```

## 4. Validate Helm chart structure and values

- Check that the `todoapp` Helm chart and its `mysql` sub-chart exist in the correct directories.
- Inspect `values.yaml` files to ensure all required parameters (namespace, secrets, resources, image, affinity, etc.) are present and used in templates via Helm functions (e.g., `range`, `.Chart.Name`).

The last command in the [bootstrap.sh](./bootstrap.sh) file displayed the rendered manifests.

## 5. Check resource creation

- List all resources to verify creation:

```sh
kubectl get all,cm,secret,ing -A > output.log
```
- Confirm the output is saved in `output.log` in the repository root.

## 6. Test application functionality

- Visit http://localhost:30007 and verify the ToDo app UI loads.