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
# Jenkins Resources
##################################################################################

# ALB Security Group
resource "aws_security_group" "jenkins_lb_sg" {
  name              = "tf-${var.app_name}-jenkins-lb-sg"
  description       = "Security group for Experts Demo Jenkins LB"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["${var.ingress_cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id            = "${module.vpc.vpc_id}"
  tags              = "${merge(var.tags, map("Name", format("tf-%s-jenkins-lb-sg", var.app_name)))}"
}

# Instance Security Group
resource "aws_security_group" "jenkins_instance_sg" {
  name              = "tf-${var.app_name}-jenkins-instance-sg"
  description       = "Security group for Experts Demo Jenkins Instance"
  vpc_id            = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.jenkins_lb_sg.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.ingress_cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags              = "${merge(var.tags, map("Name", format("tf-%s-jenkins-instance-sg", var.app_name)))}"
}

resource "aws_lb" "jenkins_lb" {
  name                      = "tf-${var.app_name}-jenkins-lb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = ["${aws_security_group.jenkins_lb_sg.id}"]
  subnets                   = ["${module.vpc.public_subnets}"]
  tags                      = "${merge(var.tags, map("Name", format("tf-%s-jenkins-lb", var.app_name)))}"
}

resource "aws_lb_target_group" "jenkins_lb_targets" {
  name_prefix               = "tg-"
  port                      = 8080
  protocol                  = "HTTP"
  vpc_id                    = "${module.vpc.vpc_id}"

  health_check {
    healthy_threshold       = 2
    interval                = 15
    path                    = "/login"
    timeout                 = 10
    unhealthy_threshold     = 2
    matcher                 = "200"
  }

  tags                      = "${merge(var.tags, map("Name", "jenkins-tg"))}"

  depends_on                = ["aws_lb.jenkins_lb"]
}

resource "aws_lb_listener" "phish_threat_nginx_alb_listener_http" {
  load_balancer_arn         = "${aws_lb.jenkins_lb.arn}"
  port                      = "8080"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = "${aws_lb_target_group.jenkins_lb_targets.arn}"
  }
}

resource "aws_launch_configuration" "jenkins_lc" {
  name_prefix                 = "jenkins-lc-"
  image_id                    = "${data.aws_ami.demo.id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.jenkins_instance_sg.id}"]
  user_data                   = "${data.template_file.jenkins-app.rendered}"
  key_name                    = "${var.ssh_key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  lifecycle {
    create_before_destroy     = true
  }
}

# AutoScalingGroup Creation #
/*
    Even though a lifecycle has been included and the name of the launch configuration tied to the ASG,
    the launch configuration will only update and not trigger my autoscale group to start up a new instance
    and kill the previous one when updating user data or AMI.
    Solution: Force a redeployment when launch configuration changes. You can set the name of the ASG
              to use the name of the generated launch config to force a re-create automatically
*/
resource "aws_autoscaling_group" "jenkins_asg" {
  name                      = "${aws_launch_configuration.jenkins_lc.name}-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  desired_capacity          = "${var.desired_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  force_delete              = "${var.force_delete}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  launch_configuration      = "${aws_launch_configuration.jenkins_lc.name}"
  target_group_arns         = ["${aws_lb_target_group.jenkins_lb_targets.arn}"]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy   = true
  }

  timeouts {
    delete                  = "15m"
  }

  tag {
    key                     = "Name"
    value                   = "${format("%s-asg", aws_launch_configuration.jenkins_lc.name)}"
    propagate_at_launch     = true
  }
}
