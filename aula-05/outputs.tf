output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}
output "ec2_public_ip" {
  value = aws_instance.api.public_ip
}
output "connection_string" {
  value = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name}"
}
