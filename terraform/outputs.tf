##################################################################################
# OUTPUT
##################################################################################

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "jenkins_asg_name" {
  value = "${aws_autoscaling_group.jenkins_asg.name}"
}

output "app_asg_name" {
  value = "${aws_autoscaling_group.app_asg.name}"
}

output "jenkins_lb_name" {
  value = "${aws_lb.jenkins_lb.name}"
}

output "jenkins_lb_arn" {
  value = "${aws_lb.jenkins_lb.arn}"
}

output "app_lb_arn" {
  value = "${aws_lb.app_lb.arn}"
}

output "jenkins_lb_fqdn" {
  value = "${aws_lb.jenkins_lb.dns_name}"
}

output "app_lb_fqdn" {
  value = "${aws_lb.app_lb.dns_name}"
}
