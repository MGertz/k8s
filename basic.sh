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
echo -e ${RED}



number_of_actions=28

# variables

dist_version=$(lsb_release -cs)
lsb_dist="$(. /etc/os-release && echo "$ID")"



# 1
function remove_old_docker() {
    # Remove all old versions of docker
    echo -e "${START_COLOR} 1/$number_of_actions Removed oldversions of docker${NC}"
    sudo apt-get remove docker-compose docker.io-doc docker2aci docker-doc docker-ce docker.io docker docker-clean docker-registry docker-ce -y
}

# 2 
function prep_system() {
    #disable automaticly upgrade
    echo -e "${START_COLOR} 2/$number_of_actions Prepping System${NC}"
    echo -e "  - Disable automaticly upgrade${NC}"
    echo -e "APT::Periodic::Update-Package-Lists \"0\";\nAPT::Periodic::Unattended-Upgrade \"0\";\n"  | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

    echo -e "  - Disable needrestart${NC}"
    sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
}

# 
function add_missing_repositories() {
    # Adding missing repository
    echo -e "${START_COLOR} 3/$number_of_actions Adding docker repository${NC}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$lsb_dist $dist_version stable" | sudo tee /etc/apt/sources.list.d/docker.list

    echo -e "${START_COLOR} 4/$number_of_actions Adding repository for kubernetes${NC}"

    echo -e "${START_COLOR}   - Google cloud package${NC}"
    curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg

    echo -e "${START_COLOR}   - deb package${NC}"
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Install kubernetes
    echo -e "${START_COLOR} 5/$number_of_actions apt update${NC}"
    sudo apt-get update
}

# 4
function install_packages() {
    # Install nessesary packages
    echo -e "${START_COLOR} 6/$number_of_actions Update and Install needed packages.${NC}"

    echo -e "${START_COLOR}   - apt update${NC}"
    sudo apt-get update

    echo -e "${START_COLOR}   - apt upgrade${NC}"
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

    echo -e "${START_COLOR}   - apt autoremove${NC}"
    sudo apt-get autoremove -y

    echo -e "${START_COLOR}   - apt install${NC}"
    #sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 vim git software-properties-common containerd.io docker-ce docker-ce-cli kubelet kubeadm kubectl
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 vim git software-properties-common docker-ce docker-ce-cli kubelet kubeadm kubectl

    echo -e "${START_COLOR}   - hold kubexxx${NC}"
    sudo apt-mark hold kubelet kubeadm kubectl
 
}

# 5
function disable_swap() {
    # Disable swap
    echo -e "${START_COLOR} 7/$number_of_actions Swap off${NC}"
    sudo swapoff -a

    # Remove Swap from fstab, else it exists after reboot
    echo -e "${START_COLOR} 8/$number_of_actions Disable swap${NC}"
    sudo sed -i "s/\/swap.img/#\/swap.img/g" /etc/fstab
}

# 6
function disable_firewall() {
    # Disable firewall
    echo -e "${START_COLOR} 9/$number_of_actions Stopping firewall${NC}"
    sudo systemctl stop ufw
    echo -e "${START_COLOR}10/$number_of_actions Disabling firewall${NC}"
    sudo systemctl disable ufw
}

#7 
function add_kernel_modules() {
    # add kernel modules
    echo -e "${START_COLOR}11/$number_of_actions Adding kerkel module${NC}"
    sudo modprobe overlay
    sudo modprobe br_netfilter

    echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/k8s.conf

    echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/k8s.conf

    # Reload sysctl
    echo -e "${START_COLOR}12/$number_of_actions Reload Kernel modules${NC}"
    sudo sysctl --system
}

# 8
function config_docker() {
    # Make required directory
    echo -e "${START_COLOR}13/$number_of_actions creating directories${NC}"
    sudo mkdir -p /etc/systemd/system/docker.service.d

    # Create daemon json config file
    echo -e "${START_COLOR}14/$number_of_actions Create daemon config file${NC}"
    
    sudo mkdir -p /etc/docker
    echo -e "{\n  \"exec-opts\": [\"native.cgroupdriver=systemd\"],\n  \"log-driver\": \"json-file\",\n  \"log-opts\": {\n    \"max-size\": \"100m\"\n  },\n  \"storage-driver\": \"overlay2\"\n}" | sudo tee /etc/docker/daemon.json

    # Start and enable Services
    echo -e "${START_COLOR}15/$number_of_actions Restarting daemon${NC}"
    sudo systemctl daemon-reload 
    
    echo -e "${START_COLOR}16/$number_of_actions Restarting docker${NC}"
    sudo systemctl restart docker
    
    echo -e "${START_COLOR}17/$number_of_actions Enable daemon${NC}"
    sudo systemctl enable docker
}

# 9
function install_cri_docker() {
    # get the latest release version:
    echo -e "${START_COLOR}18/$number_of_actions get latest version of cri-dockerd${NC}"
    VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
    echo $VER


    #We can then download the archive file from Github cri-dockerd releases page.
    echo -e "${START_COLOR}19/$number_of_actions Download latest version of cri-dockerd${NC}"
    wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
    
    echo -e "${START_COLOR}20/$number_of_actions extract latest version of cri-dockerd${NC}"
    tar xvf cri-dockerd-${VER}.amd64.tgz

    #Move cri-dockerd binary package to /usr/local/bin directory
    echo -e "${START_COLOR}21/$number_of_actions move latest version of cri-dockerd${NC}"
    sudo mv cri-dockerd/cri-dockerd /usr/local/bin/


    # Configure systemd units for cri-dockerd:
    echo -e "${START_COLOR}22/$number_of_actions download conf file for service${NC}"
    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
    
    echo -e "${START_COLOR}23/$number_of_actions download conf file for socket${NC}"
    wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
    
    echo -e "${START_COLOR}24/$number_of_actions move files to correct location${NC}"
    sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
    
    echo -e "${START_COLOR}25/$number_of_actions updated conf file${NC}"
    sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

    # Start and enable the services
    echo -e "${START_COLOR}26/$number_of_actions reload daemon${NC}"
    sudo systemctl daemon-reload
    
    echo -e "${START_COLOR}27/$number_of_actions enable cri-docker.service${NC}"
    sudo systemctl enable cri-docker.service
    
    echo -e "${START_COLOR}28/$number_of_actions enable cri-docker.socket${NC}"
    sudo systemctl enable --now cri-docker.socket
}

# Function to collect all needed function
function run() {
    remove_old_docker
    prep_system
    add_missing_repositories
    install_packages
    disable_swap
    disable_firewall
    add_kernel_modules
    config_docker
    install_cri_docker
}

# Execute the functions
run



