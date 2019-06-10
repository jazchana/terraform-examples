variable "region" {
  default = "eu-west-1"
}

variable "availability_zones" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "basic_amazon_linux_ami" {
  description = "basic amazon linux ami"
  default = "ami-06e710681e5ee07aa"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "public_bastion_subnet_cidrs" {
  type = "list"
  description = "CIDR for the bastion servers"
  default = ["10.0.0.0/24","10.0.3.0/24"]
}

variable "private_webserver_subnet_cidrs" {
  type = "list"
  description = "CIDR for the webserver"
  default = ["10.0.1.0/24","10.0.4.0/24"]
}

variable "private_database_subnet_cidrs" {
  type = "list"
  description = "CIDR for the database servers"
  default = ["10.0.2.0/24","10.0.5.0/24"]
}


variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/Jaz/.ssh/terraformtest.pub"
}