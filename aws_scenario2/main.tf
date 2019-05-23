provider "aws" {
  region     = "${var.region}"
  profile    = "terraformtest"
}

resource "aws_vpc" "scenario2" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform_scenario2"
  }
}

resource "aws_subnet" "scenario2_public" {
  vpc_id = "${aws_vpc.scenario2.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario2_webserver"
  }
}

resource "aws_subnet" "scenario2_private" {
  vpc_id = "${aws_vpc.scenario2.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario2_database"
  }
}

resource "aws_internet_gateway" "scenario2" {
  vpc_id = "${aws_vpc.scenario2.id}"

  tags {
    Name = "terraform_scenario2"
  }
}

resource "aws_route_table" "scenario2_internet_gateway" {
  vpc_id = "${aws_vpc.scenario2.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.scenario2.id}"
  }

  tags {
    Name = "terraform_scenario2_webserver"
  }
}

resource "aws_route_table_association" "scenario2_webserver" {
  subnet_id = "${aws_subnet.scenario2_public.id}"
  route_table_id = "${aws_route_table.scenario2_internet_gateway.id}"
}

/*

NAT Gateway - helps instances in private subnet to connect to internet

*/
resource "aws_eip" "scenario2_nat_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "scenario2" {
  allocation_id = "${aws_eip.scenario2_nat_eip.id}"
  subnet_id = "${aws_subnet.scenario2_public.id}"
  depends_on = ["aws_internet_gateway.scenario2"]

  tags {
    Name = "terraform_scenario2"
  }
}

resource "aws_route_table" "scenario2_database" {
  vpc_id = "${aws_vpc.scenario2.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.scenario2.id}"
  }

  tags {
    Name = "terraform_scenario2_nat"
  }
}

resource "aws_route_table_association" "scenario2_database" {
  subnet_id = "${aws_subnet.scenario2_private.id}"
  route_table_id = "${aws_route_table.scenario2_database.id}"
}

resource "aws_security_group" "scenario2_webserver" {
  vpc_id="${aws_vpc.scenario2.id}"

  name = "scenario2_public_subnet"
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
    Name = "terraform_scenario2_webserver"
  }
}

resource "aws_security_group" "scenario2_database"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
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

  vpc_id = "${aws_vpc.scenario2.id}"

  tags {
    Name = "terraform_scenario2_database"
  }
}

# Define SSH key pair for our instances
resource "aws_key_pair" "scenario2" {
  key_name = "terraformtest"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "scenario2_webserver" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario2.id}"
  subnet_id = "${aws_subnet.scenario2_public.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario2_webserver.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${file("install.sh")}"

  tags {
    Name = "terraform_scenario2_webserver"
  }
}

resource "aws_instance" "scenario2_database" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario2.id}"
  subnet_id = "${aws_subnet.scenario2_private.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario2_database.id}"]
  source_dest_check = false

  tags {
    Name = "terraform_scenario2_database"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.scenario2_webserver.id}"
  vpc = true
}

output "web_server" {
  value = "ec2-user@${aws_eip.ip.public_ip}"
}

output "db_instance" {
  value = "ec2-user@${aws_instance.scenario2_database.private_ip}"
}