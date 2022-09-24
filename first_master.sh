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



# Print command to join cluster
#kubeadm token create --print-join-command

# Command to join another control plane
#sudo kubeadm join cp.k8s.local:6443 --token gs7pza.lalml7p4icnho3nw \
#--discovery-token-ca-cert-hash sha256:9f318d76f2623b27c456fb3c47d57e0fe7ce6fe7150e9894c9f64dbfc3bc8c05 \
#--control-plane --certificate-key 29c14c6dac7d519eaee75517d4926565009f3dac2a879d3586c22a19a015108f \
#--cri-socket unix:///run/cri-dockerd.sock 

# Command to join a worker node
#sudo kubeadm join cp.k8s.local:6443 --token gs7pza.lalml7p4icnho3nw \
#--discovery-token-ca-cert-hash sha256:9f318d76f2623b27c456fb3c47d57e0fe7ce6fe7150e9894c9f64dbfc3bc8c05\
#--cri-socket unix:///run/cri-dockerd.sock 