output "toast" {
  value = "toast"
}

output "bastion" {
  value = "${aws_instance.scenario4_bastion.*.public_ip}"
}