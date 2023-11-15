#!/bin/bash

CLI=/usr/local/bin/kind
sudo curl -Lo $CLI "https://kind.sigs.k8s.io/dl/v0.12.0/kind-$(uname)-amd64" && sudo chmod +x $CLI
kind create cluster

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/


{ clear && \
  echo -e "\n=== Kubernetes Status ===\n" && \
  kubectl get --raw '/healthz?verbose' && \
  kubectl version --short && \
  kubectl get nodes && \
  kubectl cluster-info;
} | grep -z 'Ready\| ok\|passed\|running'

kubectl get pods,services --all-namespaces
