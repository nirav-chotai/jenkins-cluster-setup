##################################################################################
# VARIABLES
##################################################################################

variable "region" {
  default     = "eu-west-1"
  description = "The AWS region to create resources in."
}

variable "env" {
  default = "dev"
}

variable "vpc_name" {
  default = "nirav_devops"
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
  default     = "2"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "public_key" {
  description = "SSH public key"
  default     = "~/.ssh/myjenkins.pub"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC."
  default = true
}

variable "jenkins_master_instance_type" {
  description = "Jenkins Master instance type"
  default     = "t2.large"
}

variable "jenkins_admin_password" {
  default = "mysupersecretpassword"
}

variable "tags" {
  type = "map"
  default = {
    Owner = "Nirav"
  }
}