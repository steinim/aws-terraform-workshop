output "db_security_group_id" {
    value = "${aws_security_group.db_sg.id}"
}

output "address" {
    value = "${aws_db_instance.db.address}"
}
