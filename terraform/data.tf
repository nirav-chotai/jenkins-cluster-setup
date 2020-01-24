##################################################################################
# Data Sources
##################################################################################

data "aws_ami" "jenkins_server" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Author"
    values = ["nchotai"]
  }

  filter {
    name   = "name"
    values = ["amazon-linux-for-jenkins*"]
  }
}

# userdata for the Jenkins server ...
data "template_file" "jenkins_server" {
  template = "${file("src/jenkins_server.sh")}"

  vars {
    env = "${var.env}"
    jenkins_admin_password = "${var.jenkins_admin_password}"
  }
}