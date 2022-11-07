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
sudo yum install git -y


copying private key to .ssh folder on the local system (1 time):

cp terraform-key-pem.pem ~/.ssh/terraform-key-pem.pem

sudo chmod 600 ~/.ssh/terraform-key-pem.pem

ssh -i ~/.ssh/terraform-key-pem.pem ec2-user@54.152.180.223


aws cli for linux (optional):

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version


S3 Bucket Name: dipava-tfstate-files
Environment Folder: dev
Module1 Folder: dev/module1-vpc
Module2 Folder: dev/module2-rds