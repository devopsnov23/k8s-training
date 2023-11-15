#!/bin/bash    
   
echo "Running update and installing dependecies...."   
sudo apt update   
sudo apt install ca-certificates curl apt-transport-https -y   
   
sudo install -m 0755 -d /etc/apt/keyrings   
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg   
sudo chmod a+r /etc/apt/keyrings/docker.gpg   
   
   
echo \   
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \   
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \   
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null   
   
echo "Ïnstalling Docker..."   
sudo apt update   
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y   
   
sudo systemctl start docker   
   
sudo systemctl enable docker   
   
[ `! grep -q 'docker:' /etc/group` ] && sudo newgrp docker   
sudo usermod -aG docker $USER   
   
echo "Docker Installed successfully. Run 'docker version' to verify"   
