##################################################################################
# Security Groups
##################################################################################

# Jenkins Master
resource "aws_security_group" "jenkins_server" {
  name        = "jenkins_server"
  description = "Jenkins Server: created by Terraform"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", format("jenkins_server_sg_%s", var.vpc_name)))}"
}

# ALL INBOUND

# ssh
resource "aws_security_group_rule" "jenkins_server_from_source_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh to jenkins_server"
}

# web
resource "aws_security_group_rule" "jenkins_server_from_source_ingress_webui" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "jenkins server web"
}

# JNLP
resource "aws_security_group_rule" "jenkins_server_from_source_ingress_jnlp" {
  type              = "ingress"
  from_port         = 33453
  to_port           = 33453
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "jenkins server JNLP Connection"
}

# ALL OUTBOUND

resource "aws_security_group_rule" "jenkins_server_to_other_machines_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers to ssh to other machines"
}

resource "aws_security_group_rule" "jenkins_server_outbound_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

resource "aws_security_group_rule" "jenkins_server_outbound_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

# Jenkins Slave
resource "aws_security_group" "dev_jenkins_worker_linux" {
  name        = "dev_jenkins_worker_linux"
  description = "Jenkins Server: created by Terraform"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", format("dev_jenkins_worker_linux_sg_%s", var.vpc_name)))}"
}

# ALL INBOUND

# ssh
resource "aws_security_group_rule" "jenkins_worker_linux_from_source_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.dev_jenkins_worker_linux.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh to jenkins_worker_linux"
}

# ssh
resource "aws_security_group_rule" "jenkins_worker_linux_from_source_ingress_webui" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = "${aws_security_group.dev_jenkins_worker_linux.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh to jenkins_worker_linux"
}

# ALL OUTBOUND

resource "aws_security_group_rule" "jenkins_worker_linux_to_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.dev_jenkins_worker_linux.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins worker to all 80"
}

resource "aws_security_group_rule" "jenkins_worker_linux_to_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.dev_jenkins_worker_linux.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins worker to all 443"
}

resource "aws_security_group_rule" "jenkins_worker_linux_to_other_machines_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.dev_jenkins_worker_linux.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins worker linux to jenkins server"
}

resource "aws_security_group_rule" "jenkins_worker_linux_to_jenkins_server_8080" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.dev_jenkins_worker_linux.id}"
  source_security_group_id = "${aws_security_group.jenkins_server.id}"
  description              = "allow jenkins workers linux to jenkins server"
}


