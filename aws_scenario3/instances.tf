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