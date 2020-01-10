##################################################################################
# Data Sources
##################################################################################

data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Author"
    values = ["nchotai"]
  }

  filter {
    name   = "name"
    values = ["bastion-*"]
  }
}

data "aws_ami" "jenkins-master" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Author"
    values = ["nchotai"]
  }

  filter {
    name   = "name"
    values = ["jenkins-master-*"]
  }
}

data "aws_ami" "jenkins-slave" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Author"
    values = ["nchotai"]
  }

  filter {
    name   = "name"
    values = ["jenkins-slave-*"]
  }
}