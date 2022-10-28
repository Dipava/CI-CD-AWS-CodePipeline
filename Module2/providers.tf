terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
     source = "hashicorp/aws"
     version = "~> 4.21.0" 
     }
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
  }
    backend "s3" {
      bucket         =  "dipava-tfstate-files"
      key            = "dev/module2-rds/rds.tfstate"
      region         =  "us-east-1"
      dynamodb_table =  "module2-rds"
    }  
}

provider "aws" {
  region = "us-east-1"
}

