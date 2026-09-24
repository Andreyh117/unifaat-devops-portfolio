output "vpc_id" {
  description = "ID da VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas em ordem de chave."
  value       = [for name, subnet in aws_subnet.this : subnet.id if var.subnets[name].type == "public"]
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas em ordem de chave."
  value       = [for name, subnet in aws_subnet.this : subnet.id if var.subnets[name].type == "private"]
}
