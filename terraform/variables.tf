##################################################################################
# VARIABLES
##################################################################################

variable "region" {
  default     = "eu-west-1"
  description = "The AWS region to create resources in."
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

variable "master_public_key" {
  description = "SSH public key for master"
  default     = "~/.ssh/jenkinsMaster_rsa.pub"
}

variable "agent_public_key" {
  description = "SSH public key for agent"
  default     = "~/.ssh/jenkinsAgent_rsa.pub"
}

variable "agent_private_key" {
  description = "SSH private key for agent"
  default     = "~/.ssh/jenkinsAgent_rsa"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC."
  default = true
}

variable "jenkins_master_instance_type" {
  description = "Jenkins Master Instance Type"
  default     = "t2.large"
}

variable "jenkins_slave_instance_type" {
  description = "Jenkins Slave Instance Type"
  default     = "t2.medium"
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