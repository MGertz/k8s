#!/bin/bash

# Kør basic scriptet.
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/basic.sh | sudo sh

# Enable kubelet
echo "21/$number_of_actions Enable kubelet"
sudo systemctl enable kubelet


sudo kubeadm config images pull