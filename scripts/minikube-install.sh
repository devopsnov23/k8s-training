#!/bin/bash   
   
sudo apt update -y   
sudo apt install curl wget apt-transport-https -y   
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon -y    
[ `! grep -q 'libvirt:' /etc/group` ] && sudo newgrp libvirt   
[ `! grep -q 'libvirt-qemu:' /etc/group` ] && sudo newgrp libvirt-qemu   
   
sudo usermod -aG libvirt $USER    
sudo usermod -aG libvirt-qemu $USER    
   
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64   
   
sudo install minikube-linux-amd64 /usr/local/bin/minikube   
   
minikube version   
   
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"   
chmod +x ./kubectl   
sudo mv kubectl /usr/local/bin/   
   
kubectl version --client --output=yaml   
   
minikube start --vm-driver docker   
   
minikube status   
   
sudo rm minikube-linux-amd64   
