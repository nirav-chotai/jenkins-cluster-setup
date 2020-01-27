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
  public_key = "${file("${var.master_public_key}")}"
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

resource "aws_key_pair" "jenkins_worker_linux" {
  key_name   = "jenkins_worker_linux"
  public_key = "${file("${var.agent_public_key}")}"
}

resource "aws_launch_configuration" "jenkins_worker_linux" {
  name_prefix                 = "dev-jenkins-worker-linux"
  image_id                    = "${data.aws_ami.jenkins_worker_linux.image_id}"
  instance_type               = "t3.medium"
  iam_instance_profile        = "${aws_iam_instance_profile.dev_jenkins_worker_linux.name}"
  key_name                    = "${aws_key_pair.jenkins_worker_linux.key_name}"
  security_groups             = ["${aws_security_group.dev_jenkins_worker_linux.id}"]
  user_data                   = "${data.template_file.userdata_jenkins_worker_linux.rendered}"
  associate_public_ip_address = false

  root_block_device {
    delete_on_termination = true
    volume_size = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins_worker_linux" {
  name                      = "dev-jenkins-worker-linux"
  min_size                  = "1"
  max_size                  = "2"
  desired_capacity          = "2"
  health_check_grace_period = 60
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  launch_configuration      = "${aws_launch_configuration.jenkins_worker_linux.name}"
  termination_policies      = ["OldestLaunchConfiguration"]
  wait_for_capacity_timeout = "10m"
  default_cooldown          = 60

  tags = [
    {
      key                 = "Name"
      value               = "dev_jenkins_worker_linux"
      propagate_at_launch = true
    },
    {
      key                 = "class"
      value               = "dev_jenkins_worker_linux"
      propagate_at_launch = true
    },
  ]
}