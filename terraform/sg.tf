##################################################################################
# Security Groups
##################################################################################

resource "aws_security_group" "bastion_elb" {
  name        = "bastion_elb_sg_${var.vpc_name}"
  description = "Allow SSH from ELB SG"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = "${merge(var.tags, map("Name", format("bastion_elb_sg_%s", var.vpc_name)))}"
}

resource "aws_security_group" "bastion_host" {
  name        = "bastion_sg_${var.vpc_name}"
  description = "Allow SSH from ELB SG"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags  = "${merge(var.tags, map("Name", format("bastion_sg_%s", var.vpc_name)))}"
}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master_sg"
  description = "Allow traffic on port 8080 and enable SSH"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_host.id}"]
  }

  ingress {
    from_port       = "8080"
    to_port         = "8080"
    protocol        = "tcp"
    cidr_blocks     = ["${var.vpc_cidr}"]
    security_groups = ["${aws_security_group.elb_jenkins_sg.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = "${merge(var.tags, map("Name", format("jenkins_master_sg_%s", var.vpc_name)))}"
}

resource "aws_security_group" "jenkins_slaves_sg" {
  name        = "jenkins_slaves_sg"
  description = "Allow traffic on port 22 from Jenkins Master SG"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.jenkins_master_sg.id}", "${aws_security_group.bastion_host.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = "${merge(var.tags, map("Name", format("jenkins_slaves_sg_%s", var.vpc_name)))}"
}

resource "aws_security_group" "elb_jenkins_sg" {
  name        = "elb_jenkins_sg"
  description = "Allow http traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = "${merge(var.tags, map("Name", format("elb_jenkins_sg_%s", var.vpc_name)))}"
}