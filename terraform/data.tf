##################################################################################
# Data Sources
##################################################################################

data "aws_ami" "demo" {
  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "jenkins-app" {
  template = "${file("${path.module}/src/setup-jenkins.tpl")}"
}

data "template_file" "devops-app" {
  template = "${file("${path.module}/src/setup-app.tpl")}"
}