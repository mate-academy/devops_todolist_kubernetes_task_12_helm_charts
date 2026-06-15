# Validation Instructions
## Prerequisites
- Docker
- Kind
- Helm
- kubectl

## Setup
1. run bootstrap:
Running `./bootstrap.sh` will also generate `output.log` in the repository root.
No additional commands are required unless you want to regenerate the file.
   ```bash
    ./bootstrap.sh
   ```
2. verify deployment:
   ```bash
    kubectl get all,cm,secret,ing -A
   ```
