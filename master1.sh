#!/bin/sh
sudo apt-get update -y \n

## Installing Docker ##
sudo apt-get install -y docker.io


## Make sure that the br_netfilter module is loaded and net.bridge.bridge-nf-call-iptables is set to 1 ##
sudo bash -c 'cat << EOF > /etc/modules-load.d/k8s.conf
br_netfilter
EOF'

sudo bash -c 'cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'

sudo sysctl --system



## Installing apt-transport-https     ca-certificates     docker.io packages ##
sudo apt-get update
sudo apt-get install  -y   apt-transport-https     ca-certificates     docker.io



## Downloading the Google Cloud public signing key ## 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

## Adding the Kubernetes apt repository ##
sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list



## Installing kubelet kubeadm kubectl packages ##
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

## Hold the packages to being upgrade ##
sudo apt-mark hold kubelet kubeadm kubectl




## Adding the Docker Daemon configurations to use systemd as the cgroup driver ##
sudo bash -c 'cat << EOF > /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF'


## Restarting docker ##
sudo service docker restart




## Initialising the kubeadm on master ##
kubeadm init --control-plane-endpoint "172.31.91.10:6443" --upload-certs --pod-network-cidr=192.168.0.0/16 




sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



sudo curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O   

sudo kubectl apply -f calico.yaml

sudo kubectl get nodes
