#!/bin/bash
clear
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

START_COLOR=${CYAN}

#echo -n ${LINES}
#echo -n ${COLUMNS}

echo -e ${CYAN}
echo ' _  ___    _ ____  ______ _____  _   _ ______ _______ ______  _____  '
echo '| |/ / |  | |  _ \|  ____|  __ \| \ | |  ____|__   __|  ____|/ ____| '
echo "| ' /| |  | | |_) | |__  | |__) |  \| | |__     | |  | |__  | (___   "
echo '|  < | |  | |  _ <|  __| |  _  /| . ` |  __|    | |  |  __|  \___ \  '
echo '| . \| |__| | |_) | |____| | \ \| |\  | |____   | |  | |____ ____) | '
echo '|_|\_\\____/|____/|______|_|  \_\_| \_|______|  |_|  |______|_____/  '
echo -e "\n\n"
echo -e ${NC}

number_of_actions=7


function first_master() {
#    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
#    sleep 10

    echo -e "${START_COLOR} 1/$number_of_actions Enable kubelet${NC}"
    sudo systemctl enable kubelet

#    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
#    sleep 10

    echo -e "${START_COLOR} 2/$number_of_actions Pull images${NC}"
    sudo kubeadm config images pull --cri-socket unix:///run/cri-dockerd.sock 

#    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
#    sleep 10

    echo -e "${START_COLOR} 3/$number_of_actions Initialize cluster${NC}"
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --control-plane-endpoint=cp.k8s.local --cri-socket unix:///run/cri-dockerd.sock 
}

function config_kubectl() {
    echo -e "${START_COLOR} 4/$number_of_actions Enable kubelet${NC}"

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

function network() {
    export KUBECONFIG=/etc/kubernetes/admin.conf

    # Download network manifest
    echo -e "${START_COLOR} 5/$number_of_actions Download network manufest${NC}"
    wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

    # Apply manifest
    echo -e "${START_COLOR} 6/$number_of_actions Apply network manufest${NC}"
    kubectl apply -f kube-flannel.yml

    sleep 10

    echo -e "${START_COLOR} 7/$number_of_actions show flannel pod${NC}"
    kubectl get pods -n kube-flannel

}

first_master
config_kubectl
network
