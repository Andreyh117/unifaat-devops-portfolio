output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_ids" {
  value = [for k, v in local.subnets : aws_subnet.main[k].id if v.public]
}
output "private_subnet_ids" {
  value = [for k, v in local.subnets : aws_subnet.main[k].id if !v.public]
}
output "api_security_group_id" {
  value = aws_security_group.api.id
}
output "db_security_group_id" {
  value = aws_security_group.db.id
}
output "ec2_public_ip" {
  value = aws_instance.api.public_ip
}
output "api_url" {
  value = "http://${aws_instance.api.public_ip}:3000"
}
output "ssh_command" {
  value = "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ec2-user@${aws_instance.api.public_ip}"
}
