# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type = string
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type = string
}

# VPC Availability Zones
variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type = list(string)
}

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
}

# VPC Database Subnets
variable "vpc_database_subnets" {
  description = "VPC Database Subnets"
  type = list(string)
}

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type = bool
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type = bool
}

variable "vpc_database_subnet_group_name" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type = string
}
  
# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type = bool
}

variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type = bool
}

variable "aws_region" {
  description = "AWS Region"
  type = string
}

# AWS EC2 Instance Variables (Bastion)

variable "instance_type" {
    description = "EC2 Instance Type"
    type = string 
}

variable "instance_keypair" {
    description = "AWS EC2 Keypair for SSH Connection to Private and Bastion Instances"
    type = string
  
}






