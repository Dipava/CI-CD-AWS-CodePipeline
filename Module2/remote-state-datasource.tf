data "terraform_remote_state" "vpc" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module1-vpc/vpc.tfstate"
    region =  var.aws_region
  }
}


data "terraform_remote_state" "rdsdb_sg" {
  backend  = "s3"
  config   = {
    bucket =  "dipava-tfstate-files"
    key    =  "dev/module1-vpc/vpc.tfstate"
    region =  var.aws_region
  }
}