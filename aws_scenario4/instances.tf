resource "aws_key_pair" "scenario4" {
  key_name = "terraformtest"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "scenario4_bastion" {
  count = "${length(var.availability_zones)}"
  ami  = "${var.basic_amazon_linux_ami}"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.scenario4.id}"
  subnet_id = "${aws_subnet.scenario4_public_bastion.*.id[count.index]}"
  vpc_security_group_ids = ["${aws_security_group.scenario4_public.id}"]
  associate_public_ip_address = true

  tags {
    Name = "terraform_scenario4_bastion"
  }
}