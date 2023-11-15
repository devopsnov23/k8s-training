#!/bin/bash   
   
CLI=/usr/local/bin/kind   
sudo curl -Lo $CLI "https://kind.sigs.k8s.io/dl/v0.12.0/kind-$(uname)-amd64" && sudo chmod +x $CLI   
   
kind delete cluster > /dev/null 2>&1    
   
cat > 3node.yaml <<EOF
kind: Cluster   
apiVersion: kind.x-k8s.io/v1alpha4   
nodes:   
- role: control-plane   
- role: worker   
- role: worker   
  extraPortMappings:   
  - containerPort: 30000   
    hostPort: 30000   
  - containerPort: 32001   
    hostPort: 32001   
EOF 
   
kind create cluster --config 3node.yaml   
   
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
   
kubectl get nodes -o wide   
