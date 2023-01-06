#!/bin/bash
user=
address=
while [[ -z $address ]]; do
  read -p "SSH Address of host [none]: " address
done
read -p "SSH User of host ($address) [$USER]: " user
if [[ -z $user ]]; then
  user=$USER
fi
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
sudo service docker start
sudo apt install -y openssh-client openssh-server
ssh-keygen
sudo service ssh start
ssh-copy-id -i ~/.ssh/id_rsa.pub $user@$address
wget https://github.com/rancher/rke/releases/download/v1.4.1/rke_linux-amd64
sudo chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /bin/rke
rke config
rke up
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
wget https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz
tar -zxvf k9s_Linux_x86_64.tar.gz
sudo chmod +x k9s
sudo mv k9s /bin/
mkdir ~/.kube
cp kube_config_cluster.yml ~/.kube/config
k9s
