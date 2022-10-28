# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  # insert the 23 required variables here


  # VPC Basic Details
  name = var.vpc_name
  cidr = var.vpc_cidr_block
  azs             = var.vpc_availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # Database Subnets
  database_subnets = var.vpc_database_subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  database_subnet_group_name = var.vpc_database_subnet_group_name
 
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway 
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options =  true

  vpc_tags =  {
    Environment = "Dev"
  }

  private_subnet_tags   =  {
    Name = "Private Subnet"
  }
   public_subnet_tags   =  {
    Name = "Public Subnet"
  }
   database_subnet_tags   =  {
    Name = "database Subnet"
  }

  private_route_table_tags =  {
    Name = "Private Route table "
  }

  public_route_table_tags =  {
    Tag = "Public Route table "
  }
  
  database_route_table_tags =  {
    Tag = "database Route table "
  }
}

module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name = "public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
  tags = {
    Tag = "Public Security Group"
  }
}

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name = "private-sg"
  description = "Security Group with HTTP & SSH port open for entire VPC Block (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  egress_rules       = ["all-all"]
  tags = {
    Tag = "Private Security Group"
  }
}

module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name = "loadbalancer-sg"
  description = "Security Group with HTTP port open for entire Internet, egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  ingress_rules       = ["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 81
      protocol    = 6
      description = "Allow Port 81 from the Internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
    tags = {
    Tag = "Load-balancer Security Group"
  }
}

module "rdsdb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name = "rdsdb_sg"
  description = "Access to MySQL DB from Entire CIDR Block"
  vpc_id = module.vpc.vpc_id
  egress_rules       = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL from with VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
    tags = {
    Tag = "Database Security Group"
  }
}

resource "aws_instance" "ec2_public" {
  depends_on = [module.vpc]
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name               = var.instance_keypair
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  user_data = file("bastion-install.sh")
  tags = {
    Name = "Dev-Bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  depends_on = [aws_instance.ec2_public, module.vpc]
  instance = aws_instance.ec2_public.id
  vpc      = true
    tags = {
    Name = "Dev-Bastion-EIP"
  }
}

resource "null_resource" "name" {
  depends_on = [aws_instance.ec2_public]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type = "ssh"
    host = aws_eip.bastion_eip.public_ip
    user = "ec2-user"
    #password = ""
    private_key = file("terraform-key-pem.pem")
  }
## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "terraform-key-pem.pem"
    destination = "/tmp/terraform-key-pem.pem"
  }

## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform-key-pem.pem",
    ]
  }

}