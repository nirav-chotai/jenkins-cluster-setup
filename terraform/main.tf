##################################################################################
# Provider
##################################################################################

provider "aws" {
  region = "${var.region}"
}

##################################################################################
# Backend
##################################################################################

terraform {
  backend "s3" {
    encrypt        = true
    key            = "terraform/jenkins-setup"
    region         = "eu-west-1"
    dynamodb_table = "terraform_statelock"
  }
}

##################################################################################
# Modules
##################################################################################

module "vpc" {
  source                = "./modules/vpc"
  vpc_name              = "${var.vpc_name}"
  vpc_cidr              = "${var.vpc_cidr}"
  public_subnet_count   = "${var.public_subnet_count}"
  private_subnet_count  = "${var.private_subnet_count}"
  tags                  = "${var.tags}"
}
