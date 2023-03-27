#!/bin/bash
sudo yum update
sudo yum install -y wget

# Add Jenkins repository key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo yum upgrade
#Install Jenkins
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y

#Enable the Jenkins service to start at boot
sudo systemctl enable jenkins

#Start Jenkins as a service:
sudo systemctl start jenkins

#install git
sudo yum install git -y

#install terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

#install kubectl
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl

# Apply execute permissions to the binary.
chmod +x ./kubectl

# Copy the binary to a folder in your PATH. If you 
# have already installed a version of kubectl, then 
# we recommend creating a $HOME/bin/kubectl and 
# ensuring that $HOME/bin comes first in your $PATH.
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

# (Optional) Add the $HOME/bin path to your shell 
# initialization file so that it is configured when 
# you open a shell.
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

#aws cli
sudo yum install awscli -y

#install helm
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

#install and bootstrap flux
sudo curl -s https://fluxcd.io/install.sh | sudo bash

# Add Flux repository to Helm
helm repo add fluxcd https://charts.fluxcd.io

# Update Helm repositories
helm repo update

# Install Flux using Helm
sudo yum install flux -y

# Install Flux Helm Operator using Helm
helm upgrade -i flux-helm-operator fluxcd/flux-helm-operator --namespace flux --set git.ssh.secretName=flux-git-deploy --set helm.versions=v3