provider "aws" {
  region     = "${var.region}"
  profile    = "terraformtest"
}

resource "aws_vpc" "scenario4" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform_scenario4"
  }
}


#----------------- subnet definition -----------------------

resource "aws_subnet" "scenario4_public_bastion" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.scenario4.id}"
  cidr_block = "${var.public_bastion_subnet_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name = "terraform_scenario4_public_bastion - ${element(var.availability_zones, count.index)}"
  }
}

resource "aws_subnet" "scenario4_private_webserver" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.scenario4.id}"
  cidr_block = "${var.private_webserver_subnet_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name = "terraform_scenario4_private_webserver - ${element(var.availability_zones, count.index)}"
  }
}

resource "aws_subnet" "scenario4_private_database" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.scenario4.id}"
  cidr_block = "${var.private_database_subnet_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name = "terraform_scenario4_private_database - ${element(var.availability_zones, count.index)}"
  }
}


#----------------- internet gateway -----------------------

resource "aws_internet_gateway" "scenario4" {
  vpc_id = "${aws_vpc.scenario4.id}"

  tags {
    Name = "terraform_scenario4"
  }
}

resource "aws_route_table" "scenario4_public" {
  vpc_id = "${aws_vpc.scenario4.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.scenario4.id}"
  }

  tags {
    Name = "terraform_scenario4_internet_gateway"
  }
}

resource "aws_route_table_association" "scenario4_public" {
  count = "${length(var.availability_zones)}"
  subnet_id = "${element(aws_subnet.scenario4_public_bastion.*.id, count.index)}"
  route_table_id = "${aws_route_table.scenario4_public.id}"
}


#-------------------- nat gateway -------------------------

/*
resource "aws_eip" "scenario4_nat" {
  vpc = true
}

resource "aws_nat_gateway" "scenario4" {
  allocation_id = "${aws_eip.scenario4_nat.id}"
  subnet_id = "${aws_subnet.scenario4_public_bastion.id}"
  depends_on = ["aws_subnet.scenario4_public_bastion"]

  tags {
    Name = "terraform_scenario4"
  }
}

resource "aws_route_table" "scenario4_private" {
  vpc_id = "${aws_vpc.scenario4.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.scenario4.id}"
  }

  tags {
    Name = "terraform_scenario4_nat_gateway"
  }
}

resource "aws_route_table_association" "scenario4_webserver" {
  subnet_id = "${aws_subnet.scenario4_private_webserver.id}"
  route_table_id = "${aws_route_table.scenario4_private.id}"
}

resource "aws_route_table_association" "scenario4_database" {
  subnet_id = "${aws_subnet.scenario4_private_database.id}"
  route_table_id = "${aws_route_table.scenario4_private.id}"
}
*/

