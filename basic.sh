#!/bin/bash
number_of_actions=10


# variables
echo "1/$number_of_actions Collect variables"
dist_version=$(lsb_release -cs)
lsb_dist="$(. /etc/os-release && echo "$ID")"

pause 'press [enter] to continue...'

# Install nessesary packages
echo "2/$number_of_actions Update and Install needed packages."
sudo apt update > /dev/null
sudo apt upgrade -y > /dev/null
sudo apt autoremove -y > /dev/null
sudo apt install apt-transport-https ca-certificates curl gnupg2 vim git software-properties-common -y > /dev/null

pause 'press [enter] to continue...'

# Disable swap
echo "Swap off"
sudo swapoff -a

# Remove Swap from fstab, else it exists after reboot
echo "Disable swap"
sudo sed -i "s/\/swap.img/#\/swap.img/g" /etc/fstab

pause 'press [enter] to continue...'

# Disable firewall
echo "Stopping firewall"
sudo systemctl stop ufw
echo "Disabling firewall"
sudo systemctl disable ufw

pause 'press [enter] to continue...'

# add kernel modules
echo "Adding kerkel module"
sudo modprove overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Reload sysctl
echo "Reload Kernel modules"
sudo sysctl --system

# Remove all old versions of docker
echo "Removed oldversions of docker"
sudo apt remove docker-compose docker.io-doc docker2aci docker-doc docker-ce docker.io docker docker-clean docker-registry docker-ce -y

# Adding docker repository

# en gammel måde at gøre det på
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$lsb_dist $dist_version stable" > /etc/apt/sources.list.d/docker.list
sudo apt update


# Install Docker
echo "Install new docker version"
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Make required directory
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker








