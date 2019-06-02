variable "region" {
  default = "eu-west-1"
}

variable "availability_zone" {
  default = "eu-west-1a"
}

variable "amis" {
  type = "map"
  default = {
    "aws-linux-ami" = "ami-06e710681e5ee07aa"
    "aws-linux2-ami" = "ami-08935252a36e25f85"
  }
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}


variable "webserver_subnet_cidr" {
  description = "CIDR for the Webserver Subnet"
  default = "10.0.1.0/24"
}


variable "database_subnet_cidr" {
  description = "CIDR for the database Subnet"
  default = "10.0.2.0/24"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/Jaz/.ssh/terraformtest.pub"
}