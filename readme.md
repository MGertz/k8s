# K8s setup Scripts

This is how to run the script

Before running the scripts, prep the system by running the following command, it will restart the server in the end.
```bash
sudo apt update; \
sudo apt upgrade -y; \
sudo apt autoremove -y; \
sudo apt install libnss-systemd libpam-systemd libsystemd0 libudev1 systemd systemd-sysv systemd-timesyncd udev -y; \
sudo reboot
```


## Basic Script
To do the basic setup of kubernetes first run this script on all machines which is going to be part of the kubernetes cluster

```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/basic.sh | bash
```

## Setup first Control Plane master
This script will initialize the first control plane master, and add network for pods

```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/first_master.sh | bash
```

## Setup Dashboard
Install dashboard for a simple way of controlling the cluster

```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/dashboard.sh | bash
```

Command to generate tokens to connect to dashboard

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

## Test deployment
Run this command to deploy a nginx webserver

```bash
wget https://raw.githubusercontent.com/MGertz/k8s/main/deployments/test-mysite.yml; \
kubectl apply -f test-mysite.yml
```



---
# Where comes the knowledge from
The scripts is based on the following articles
### DIFFERENT LINKS FOR THIS SCRIPT
Script is based on the following tutorial

https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/

https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/


# Commands for joining a control plane or worker node

## Print command to join cluster
kubeadm token create --print-join-command

## Command to join another control plane
sudo kubeadm join cp.k8s.local:6443 --token gs7pza.lalml7p4icnho3nw \
--discovery-token-ca-cert-hash sha256:9f318d76f2623b27c456fb3c47d57e0fe7ce6fe7150e9894c9f64dbfc3bc8c05 \
--control-plane --certificate-key 29c14c6dac7d519eaee75517d4926565009f3dac2a879d3586c22a19a015108f \
--cri-socket unix:///run/cri-dockerd.sock 

## Command to join a worker node
sudo kubeadm join cp.k8s.local:6443 --token gs7pza.lalml7p4icnho3nw \
--discovery-token-ca-cert-hash sha256:9f318d76f2623b27c456fb3c47d57e0fe7ce6fe7150e9894c9f64dbfc3bc8c05\
--cri-socket unix:///run/cri-dockerd.sock 