##################################################################################
# OUTPUT
##################################################################################

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "bastion_ami" {
  value = "${data.aws_ami.bastion.id}"
}

output "bastion_elb" {
  value = "${aws_elb.bastion_hosts_elb.dns_name}"
}

output "jenkins_master_ami" {
  value = "${data.aws_ami.jenkins-master.id}"
}

output "jenkins_slave_ami" {
  value = "${data.aws_ami.jenkins-slave.id}"
}

output "jenkins_master_elb" {
  value = "${aws_elb.jenkins_elb.dns_name}"
}
