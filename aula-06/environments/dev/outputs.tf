output "vpc_id" {
  description = "ID da VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Subnets públicas."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Subnets privadas."
  value       = module.vpc.private_subnet_ids
}

output "instance_id" {
  description = "ID da EC2."
  value       = module.api_server.instance_id
}

output "public_ip" {
  description = "IP público EC2."
  value       = module.api_server.public_ip
}

output "private_ip" {
  description = "IP privado EC2."
  value       = module.api_server.private_ip
}

output "db_endpoint" {
  description = "Endpoint RDS."
  value       = module.database.db_endpoint
}

output "db_name" {
  description = "Nome do database."
  value       = module.database.db_name
}

output "db_port" {
  description = "Porta PostgreSQL."
  value       = module.database.db_port
}
