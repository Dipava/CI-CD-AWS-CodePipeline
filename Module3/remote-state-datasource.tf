data "terraform_remote_state" "vpc" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module1-vpc/vpc.tfstate"
    region =  var.aws_region
  }
}

data "terraform_remote_state" "loadbalancer_sg" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module1-vpc/vpc.tfstate"
    region =  var.aws_region
  }
}

data "terraform_remote_state" "private_sg" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module1-vpc/vpc.tfstate"
    region =  var.aws_region
  }
}


data "terraform_remote_state" "rdsdb" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module2-rds/rds.tfstate"
    region =  var.aws_region
  }
}