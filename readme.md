# K8s setup Scripts

This is how to run the script

## Basic Script
To do the basic setup of kubernetes first run this script on all machines which is going to be part of the kubernetes cluster

```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/basic.sh | sudo sh
```



# Final way of calling the different scripts
## Master Script
```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/master.sh | sudo sh
```

## Node Script
```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/node.sh | sudo sh
```



---
# Where comes the knowledge from
The scripts is based on the following articles
### DIFFERENT LINKS FOR THIS SCRIPT
# Script is based on the following tutorial
# https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/
# https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/

