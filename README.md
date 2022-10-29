# CI-CD-AWS-CodePipeline
Implement Terraform IAC DevOps for AWS Project with Jenkins Pipeline

user-data for jenkins server:

#! /bin/bash
sudo yum update –y
sudo amazon-linux-extras install java-openjdk11 -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
yum install git -y


copying private key to .ssh folder on the local system (1 time):

cp terraform-key-pem.pem ~/.ssh/terraform-key-pem.pem

sudo chmod 600 ~/.ssh/terraform-key-pem.pem

ssh -i ~/.ssh/terraform-key-pem.pem ec2-user@34.228.24.20


aws cli for linux install (optional):

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install