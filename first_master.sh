function first_master() {
    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
    sleep 10

    echo -e "${START_COLOR}29/$number_of_actions Enable kubelet${NC}"
    sudo systemctl enable kubelet

    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
    sleep 10

    echo -e "${START_COLOR}30/$number_of_actions Pull images${NC}"
    sudo kubeadm config images pull --cri-socket unix:///run/cri-dockerd.sock 

    echo -e "${START_COLOR}SLEET 10 SEC${NC}"
    sleep 10

    echo -e "${START_COLOR}31/$number_of_actions Initialize cluster${NC}"
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --control-plane-endpoint=cp.k8s.local --cri-socket unix:///run/cri-dockerd.sock 
}

function network() {
    export KUBECONFIG=/etc/kubernetes/admin.conf

    # Download network manifest
    echo -e "${START_COLOR}Download network manufest${NC}"
    wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

    # Apply manifest
    echo -e "${START_COLOR}Apply network manufest${NC}"
    kubectl apply -f kube-flannel.yml

    kubectl get pods -n kube-flannel

    # Print command to join cluster
    kubeadm token create --print-join-command
}

first_master
network