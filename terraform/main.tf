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
# VPC Setup
##################################################################################

module "vpc" {
  source                = "./modules/vpc"
  vpc_name              = "${var.vpc_name}"
  vpc_cidr              = "${var.vpc_cidr}"
  public_subnet_count   = "${var.public_subnet_count}"
  private_subnet_count  = "${var.private_subnet_count}"
  tags                  = "${var.tags}"
}

##################################################################################
# Jenkins Server Setup
##################################################################################

resource "aws_key_pair" "jenkins_server" {
  key_name   = "jenkins_server"
  public_key = "${file("${var.public_key}")}"
}

resource "aws_instance" "jenkins_server" {
  ami                         = "${data.aws_ami.jenkins_server.id}"
  instance_type               = "${var.jenkins_master_instance_type}"
  key_name                    = "${aws_key_pair.jenkins_server.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.jenkins_server.id}"]
  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
  iam_instance_profile        = "${aws_iam_instance_profile.jenkins_server.name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.jenkins_server.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  tags  = "${merge(var.tags, map("Name", "jenkins_server"))}"
}

##################################################################################
# Jenkins Slave Setup
##################################################################################

