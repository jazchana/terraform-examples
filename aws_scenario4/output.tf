output "bastions" {
  value = "${aws_instance.scenario4_bastion.*.public_ip}"
}

output "webservers" {
  value = "${aws_instance.scenario4_webserver.*.private_ip}"
}

output "databases" {
  value = "${aws_instance.scenario4_database.*.private_ip}"
}