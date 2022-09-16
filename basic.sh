#!/bin/bash
number_of_actions=16

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
sudo systemctl stop ufw
echo " 6/$number_of_actions Disabling firewall"
sudo systemctl disable ufw

# add kernel modules
echo " 7/$number_of_actions Adding kerkel module"
sudo modprobe overlay
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
echo " 8/$number_of_actions Reload Kernel modules"
sudo sysctl --system > /dev/null

# Remove all old versions of docker
echo " 9/$number_of_actions Removed oldversions of docker"
sudo apt remove docker-compose docker.io-doc docker2aci docker-doc docker-ce docker.io docker docker-clean docker-registry docker-ce -y > /dev/null

# Adding docker repository
echo "10/$number_of_actions Adding docker repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$lsb_dist $dist_version stable" > /etc/apt/sources.list.d/docker.list
sudo apt update > /dev/null

# Install Docker
echo "11/$number_of_actions Install new docker version"
sudo apt install -y containerd.io docker-ce docker-ce-cli > /dev/null

# Make required directory
echo "12/$number_of_actions creating directories"
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
echo "13/$number_of_actions Create daemon config file"
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF > /dev/null

# Start and enable Services
echo "14/$number_of_actions Restarting daemon"
sudo systemctl daemon-reload  > /dev/null
echo "15/$number_of_actions Restarting docker"
sudo systemctl restart docker > /dev/null
echo "16/$number_of_actions Enable daemon"
sudo systemctl enable docker > /dev/null








