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
    jenkins_admin_password  = "${var.jenkins_admin_password}"
  }
}

data "aws_ami" "jenkins_worker_linux" {
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

data "tls_public_key" "example" {
  private_key_pem = "${file("${var.agent_private_key}")}"
}

data "template_file" "userdata_jenkins_worker_linux" {
  template = "${file("src/jenkins_worker_linux.sh")}"

  vars {
    server_ip         = "${aws_instance.jenkins_server.private_ip}"
    jenkins_username  = "admin"
    jenkins_password  = "${var.jenkins_admin_password}"
    device_name       = "eth0"
    worker_pem        = "${data.tls_public_key.example.private_key_pem}"
  }
}