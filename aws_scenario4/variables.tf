variable "region" {
  default = "eu-west-1"
}

availability_zones = ["eu-west-1a", "eu-west-1b"]

amazon_linux_ami = "ami-06e710681e5ee07aa"

variable "ami" {
  description = "basic amazon linux ami"
  default = "ami-06e710681e5ee07aa"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "az1_public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}


variable "az1_webserver_subnet_cidr" {
  description = "CIDR for the Webserver Subnet"
  default = "10.0.1.0/24"
}


variable "az1_database_subnet_cidr" {
  description = "CIDR for the database Subnet"
  default = "10.0.2.0/24"
}

variable "az2_public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.3.0/24"
}


variable "az2_webserver_subnet_cidr" {
  description = "CIDR for the Webserver Subnet"
  default = "10.0.4.0/24"
}


variable "az2_database_subnet_cidr" {
  description = "CIDR for the database Subnet"
  default = "10.0.5.0/24"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/Jaz/.ssh/terraformtest.pub"
}