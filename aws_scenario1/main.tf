provider "aws" {
  region     = "${var.region}"
  profile    = "terraformtest"
}

#define the vpc
resource "aws_vpc" "scenario1" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform_scenario1"
  }
}

#define the public subnet
resource "aws_subnet" "scenario1" {
  vpc_id = "${aws_vpc.scenario1.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario1"
  }
}

#define the internet gateway
resource "aws_internet_gateway" "scenario1" {
  vpc_id = "${aws_vpc.scenario1.id}"

  tags {
    Name = "terraform_scenario1"
  }
}

#define the route table
resource "aws_route_table" "scenario1" {
  vpc_id = "${aws_vpc.scenario1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.scenario1.id}"
  }

  tags {
    Name = "terraform_scenario1"
  }
}

#define association to public subnet
resource "aws_route_table_association" "scenario1" {
  subnet_id = "${aws_subnet.scenario1.id}"
  route_table_id = "${aws_route_table.scenario1.id}"
}


#define the security group for the public subnet
resource "aws_security_group" "scenario1" {
  vpc_id="${aws_vpc.scenario1.id}"

  name = "scenario1_public_subnet"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform_scenario1"
  }
}

# Define SSH key pair for our instances
resource "aws_key_pair" "scenario1" {
  key_name = "terraformtest"
  public_key = "${file("${var.key_path}")}"
}

#create the web server instance
resource "aws_instance" "scenario1" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario1.id}"
  subnet_id = "${aws_subnet.scenario1.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario1.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${file("install.sh")}"

  tags {
    Name = "terraform_scenario1_webserver"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.scenario1.id}"
  vpc = true
}

output "connection_string" {
  value = "ssh -i \"${var.key_path}\" ec2-user@${aws_eip.ip.public_ip}"
}