output "db_endpoint" {
  description = "Endpoint PostgreSQL com porta."
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "Nome do database."
  value       = aws_db_instance.this.db_name
}

output "db_port" {
  description = "Porta PostgreSQL."
  value       = aws_db_instance.this.port
}
