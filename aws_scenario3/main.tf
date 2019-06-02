provider "aws" {
  region     = "${var.region}"
  profile    = "terraformtest"
}

resource "aws_vpc" "scenario3" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform_scenario3"
  }
}


#----------------- subnet definition -----------------------


resource "aws_subnet" "scenario3_public" {
  vpc_id = "${aws_vpc.scenario3.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario3_public"
  }
}

resource "aws_subnet" "scenario3_webserver" {
  vpc_id = "${aws_vpc.scenario3.id}"

  cidr_block = "${var.webserver_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario3_webserver"
  }
}


resource "aws_subnet" "scenario3_database" {
  vpc_id = "${aws_vpc.scenario3.id}"

  cidr_block = "${var.database_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "terraform_scenario3_database"
  }
}


#----------------- internet gateway -----------------------


resource "aws_internet_gateway" "scenario3" {
  vpc_id = "${aws_vpc.scenario3.id}"

  tags {
    Name = "terraform_scenario3"
  }
}

resource "aws_route_table" "scenario3_public" {
  vpc_id = "${aws_vpc.scenario3.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.scenario3.id}"
  }

  tags {
    Name = "terraform_scenario3_internet_gateway"
  }
}

resource "aws_route_table_association" "scenario3_public" {
  subnet_id = "${aws_subnet.scenario3_public.id}"
  route_table_id = "${aws_route_table.scenario3_public.id}"
}


#-------------------- nat gateway -------------------------


resource "aws_eip" "scenario3_nat" {
  vpc = true
}

resource "aws_nat_gateway" "scenario3" {
  allocation_id = "${aws_eip.scenario3_nat.id}"
  subnet_id = "${aws_subnet.scenario3_public.id}"
  depends_on = ["aws_subnet.scenario3_public"]

  tags {
    Name = "terraform_scenario3"
  }
}

resource "aws_route_table" "scenario3_private" {
  vpc_id = "${aws_vpc.scenario3.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.scenario3.id}"
  }

  tags {
    Name = "terraform_scenario3_nat"
  }
}

resource "aws_route_table_association" "scenario3_webserver" {
  subnet_id = "${aws_subnet.scenario3_webserver.id}"
  route_table_id = "${aws_route_table.scenario3_private.id}"
}

resource "aws_route_table_association" "scenario3_database" {
  subnet_id = "${aws_subnet.scenario3_database.id}"
  route_table_id = "${aws_route_table.scenario3_private.id}"
}


#----------------- output -----------------------


output "bastion" {
  value = "ec2-user@${aws_eip.bastion_ip.public_ip}"
}

output "web_server" {
  value = "ec2-user@${aws_instance.scenario3_webserver.private_ip}"
}

output "db_instance" {
  value = "ec2-user@${aws_instance.scenario3_database.private_ip}"
}