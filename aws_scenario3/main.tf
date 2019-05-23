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
    cidr_block = "10.0.0.0/0"
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


#----------------- security groups -----------------------


resource "aws_security_group" "scenario3_public" {
  vpc_id="${aws_vpc.scenario3.id}"

  name = "scenario3_public_subnet"
  description = "Allow incoming HTTP connections & SSH access"

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

  tags {
    Name = "terraform_scenario3_webserver"
  }
}

resource "aws_security_group" "scenario3_webserver" {
  vpc_id="${aws_vpc.scenario3.id}"

  name = "scenario3_webserver_subnet"
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

  tags {
    Name = "terraform_scenario3_webserver"
  }
}

resource "aws_security_group" "scenario3_database" {
  name = "scenario3_database_subnet"
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

  vpc_id = "${aws_vpc.scenario3.id}"

  tags {
    Name = "terraform_scenario3_database"
  }
}


#----------------- instances -----------------------


resource "aws_key_pair" "scenario3" {
  key_name = "terraformtest"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_eip" "bastion_ip" {
  instance = "${aws_instance.scenario3_bastion.id}"
  depends_on = ["aws_instance.scenario3_bastion"]
  vpc = true
}

resource "aws_instance" "scenario3_bastion" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario3.id}"
  subnet_id = "${aws_subnet.scenario3_public.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario3_public.id}"]
  source_dest_check = false

  tags {
    Name = "terraform_scenario3_bastion"
  }
}

resource "aws_instance" "scenario3_webserver" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario3.id}"
  subnet_id = "${aws_subnet.scenario3_public.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario3_webserver.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${file("install.sh")}"

  tags {
    Name = "terraform_scenario3_webserver"
  }
}

resource "aws_instance" "scenario3_database" {
  ami  = "${var.amis["aws-linux-ami"]}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario3.id}"
  subnet_id = "${aws_subnet.scenario3_database.id}"
  vpc_security_group_ids = ["${aws_security_group.scenario3_database.id}"]
  source_dest_check = false

  tags {
    Name = "terraform_scenario3_database"
  }
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