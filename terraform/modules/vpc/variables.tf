##################################################################################
# VARIABLES
##################################################################################

variable "vpc_name" {
  default = "nirav-devops"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "172.20.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  default     = "1"
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  default     = "1"
}

variable "tags" {
  type = "map"
  default = {
    Owner = "Nirav"
  }
}