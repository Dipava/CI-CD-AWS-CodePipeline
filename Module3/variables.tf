#  TERRAFORM AWS ALB VARIABLES
#App1 DNS Name
variable "app1_dns_name" {
  description = "App1 DNS Name"
}

#App2 DNS Name
variable "app2_dns_name" {
  description = "App2 DNS Name"
}

variable "instance_type" {
    description = "EC2 Instance Type"
    type = string
}

# AWS EC2 Instance Key Pair

variable "instance_keypair" {
    description = "AWS EC2 Keypair for SSH Connection to Private and Bastion Instances"
    type = string
}

# AWS EC2 Private Instance Count

variable "private_instance_count" {
    description = "Private EC2 Instance Count"
    type = number
}

variable "aws_region" {
    description = "AWS_Region"
    type = string
}
