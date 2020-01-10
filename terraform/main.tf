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

##################################################################################
# Resources - Bastion Creation
##################################################################################

# Key Pair
resource "aws_key_pair" "demo" {
  key_name   = "jenkins"
  public_key = "${file("${var.public_key}")}"
}

# Bastion ELB
resource "aws_elb" "bastion_hosts_elb" {
  subnets                   = ["${module.vpc.public_subnets}"]
  cross_zone_load_balancing = true
  security_groups           = ["${aws_security_group.bastion_elb.id}"]

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }

  tags  = "${merge(var.tags, map("Name", format("bastion_elb_%s", var.vpc_name)))}"
}

# Bastion Launch Configuration
resource "aws_launch_configuration" "bastion_conf" {
  name_prefix     = "bastion-"
  image_id        = "${data.aws_ami.bastion.id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.demo.key_name}"
  security_groups = ["${aws_security_group.bastion_host.id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion ASG
resource "aws_autoscaling_group" "bastion_asg" {
  name                 = "${aws_launch_configuration.bastion_conf.name}-asg"
  launch_configuration = "${aws_launch_configuration.bastion_conf.name}"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]
  load_balancers       = ["${aws_elb.bastion_hosts_elb.name}"]
  min_size             = 1
  max_size             = 1

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete                  = "15m"
  }

  tag {
    key                     = "Name"
    value                   = "${format("%s-asg", aws_launch_configuration.bastion_conf.name)}"
    propagate_at_launch     = true
  }
}

##################################################################################
# Resources - Jenkins Master Creation
##################################################################################

resource "aws_instance" "jenkins_master" {
  ami                     = "${data.aws_ami.jenkins-master.id}"
  instance_type           = "${var.jenkins_master_instance_type}"
  key_name                = "${aws_key_pair.demo.key_name}"
  vpc_security_group_ids  = ["${aws_security_group.jenkins_master_sg.id}"]
  subnet_id               = "${element(module.vpc.private_subnets, 0)}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  tags  = "${merge(var.tags, map("Name", "jenkins_master"))}"
}

// Jenkins Master ELB
resource "aws_elb" "jenkins_elb" {
  subnets                   = ["${module.vpc.public_subnets}"]
  cross_zone_load_balancing = true
  security_groups           = ["${aws_security_group.elb_jenkins_sg.id}"]
  instances                 = ["${aws_instance.jenkins_master.id}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 5
  }

  tags  = "${merge(var.tags, map("Name", "jenkins_elb"))}"
}

##################################################################################
# Resources - Jenkins Slave Creation
##################################################################################

# Jenkins slaves resource template
data "template_file" "user_data_slave" {
  template = "${file("src/join-cluster.tpl")}"

  vars {
    jenkins_url            = "http://${aws_instance.jenkins_master.private_ip}:8080"
    jenkins_username       = "${var.jenkins_username}"
    jenkins_password       = "${var.jenkins_password}"
    jenkins_credentials_id = "${var.jenkins_credentials_id}"
  }
}

// Jenkins slaves launch configuration
resource "aws_launch_configuration" "jenkins_slave_launch_conf" {
  name_prefix          = "slave_lc_"
  image_id             = "${data.aws_ami.jenkins-slave.id}"
  instance_type        = "${var.jenkins_slave_instance_type}"
  key_name             = "${aws_key_pair.demo.key_name}"
  security_groups      = ["${aws_security_group.jenkins_slaves_sg.id}"]
  user_data            = "${data.template_file.user_data_slave.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.profile.arn}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ASG Jenkins slaves
resource "aws_autoscaling_group" "jenkins_slaves" {
  name                 = "${aws_launch_configuration.jenkins_slave_launch_conf.name}-asg"
  launch_configuration = "${aws_launch_configuration.jenkins_slave_launch_conf.name}"
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]
  min_size             = "${var.min_jenkins_slaves}"
  max_size             = "${var.max_jenkins_slaves}"

  depends_on = ["aws_instance.jenkins_master", "aws_elb.jenkins_elb"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                     = "Name"
    value                   = "${format("%s-asg", aws_launch_configuration.jenkins_slave_launch_conf.name)}"
    propagate_at_launch     = true
  }
}