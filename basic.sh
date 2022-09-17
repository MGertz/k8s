#!/bin/bash
clear

echo '  ^ ^                      '
echo ' (O,O)                     '
echo ' (   ) Kubernetes Setup    '
echo ' -"-"----------------------\n\n'


number_of_actions=20

# variables
echo " 1/$number_of_actions Collect variables"
dist_version=$(lsb_release -cs)
lsb_dist="$(. /etc/os-release && echo "$ID")"

# Install nessesary packages
echo " 2/$number_of_actions Update and Install needed packages."
echo "   - apt update"
sudo apt-get update > /dev/null
echo "   - apt upgrade"
sudo apt-get upgrade -y > /dev/null
echo "   - apt autoremove"
sudo apt-get autoremove -y > /dev/null
echo "   - apt install"
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 vim git software-properties-common -y > /dev/null

# Disable swap
echo " 3/$number_of_actions Swap off"
sudo swapoff -a > /dev/null

# Remove Swap from fstab, else it exists after reboot
echo " 4/$number_of_actions Disable swap"
sudo sed -i "s/\/swap.img/#\/swap.img/g" /etc/fstab

# Disable firewall
echo " 5/$number_of_actions Stopping firewall"
sudo systemctl stop ufw > /dev/null
echo " 6/$number_of_actions Disabling firewall"
sudo systemctl disable ufw > /dev/null

# add kernel modules
echo " 7/$number_of_actions Adding kerkel module"
sudo modprobe overlay
sudo modprobe br_netfilter

sudo touch /etc/modules-load.d/k8s.conf
sudo echo "overlay" >> /etc/modules-load.d/k8s.conf
sudo echo "br_netfilter" >> /etc/modules-load.d/k8s.conf

sudo touch /etc/sysctl.d/k8s.conf
sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf
sudo echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf
sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf

# Reload sysctl
echo " 8/$number_of_actions Reload Kernel modules"
sudo sysctl --system > /dev/null

# Remove all old versions of docker
echo " 9/$number_of_actions Removed oldversions of docker"
sudo apt-get remove docker-compose docker.io-doc docker2aci docker-doc docker-ce docker.io docker docker-clean docker-registry docker-ce -y > /dev/null

# Adding docker repository
echo "10/$number_of_actions Adding docker repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$lsb_dist $dist_version stable" > /etc/apt/sources.list.d/docker.list
sudo apt-get update > /dev/null

# Install Docker
echo "11/$number_of_actions Install new docker version"
sudo apt-get install -y containerd.io docker-ce docker-ce-cli > /dev/null

# Make required directory
echo "12/$number_of_actions creating directories"
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
echo "13/$number_of_actions Create daemon config file"
sudo touch /etc/docker/daemon.json
sudo echo "{" >> /etc/docker/daemon.json
sudo echo '  "exec-opts": ["native.cgroupdriver=systemd"],' >> /etc/docker/daemon.json
sudo echo '  "log-driver": "json-file",' >> /etc/docker/daemon.json
sudo echo '  "log-opts": {' >> /etc/docker/daemon.json
sudo echo '    "max-size": "100m"' >> /etc/docker/daemon.json
sudo echo '    "max-size": "100m"' >> /etc/docker/daemon.json
sudo echo '  },' >> /etc/docker/daemon.json
sudo echo '  "storage-driver": "overlay2"' > /etc/docker/daemon.json
sudo echo '}' >> /etc/docker/daemon.json

# Start and enable Services
echo "14/$number_of_actions Restarting daemon"
sudo systemctl daemon-reload  > /dev/null
echo "15/$number_of_actions Restarting docker"
sudo systemctl restart docker > /dev/null
echo "16/$number_of_actions Enable daemon"
sudo systemctl enable docker > /dev/null

# Adding repository for kubernetes
echo "17/$number_of_actions Adding repository for kubernetes"
echo "   - Google cloud package"
curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
echo "   - Google cloud package 2"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "   - deb package"
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubernetes
echo "18/$number_of_actions apt update"
sudo apt-get update > /dev/null
echo "19/$number_of_actions apt install packages"
sudo apt-get install kubelet kubeadm kubectl -y > /dev/null
echo "20/$number_of_actions lock kubernetes to specific version"
sudo apt-mark hold kubelet kubeadm kubectl





