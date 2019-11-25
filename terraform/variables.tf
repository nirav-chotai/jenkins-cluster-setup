##################################################################################
# VARIABLES
##################################################################################

variable "app_name" {
  description = "Application Name"
  default = "experts-demo"
}

variable "region" {
  default     = "eu-west-1"
  description = "The AWS region to create resources in."
}

variable "vpc_name" {
  default = "nirav-devops"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "172.20.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  default     = "2"
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  default     = "1"
}

variable "ingress_cidr_block" {
  description = "Allowed connection from the IP or IP range"
  default = "14.140.133.58/32"
}

variable "ssh_key_name" {
  description = "The key name that should be used for the instance."
  default = "experts-demo"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default = "m4.large"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC."
  default = true
}

variable "max_size" {
  description = "The maximum size of the auto scale group."
  default = "1"
}

variable "min_size" {
  description = "The minimum size of the auto scale group."
  default = "1"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  default = "1"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  default = "300"
}

variable "health_check_type" {
  description = "EC2 or ELB"
  default = "EC2"
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations."
  default = false
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate."
  default = true
}

variable "tags" {
  type = "map"
  default = {
    Owner = "Nirav"
  }
}