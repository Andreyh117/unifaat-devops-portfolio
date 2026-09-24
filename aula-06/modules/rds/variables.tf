variable "db_name" {
  type        = string
  description = "Nome do database PostgreSQL."
}

variable "db_username" {
  type        = string
  description = "Usuário administrador."
}

variable "db_password" {
  type        = string
  description = "Senha do banco; fornecer via TF_VAR_db_password."
  sensitive   = true
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets privadas em pelo menos duas AZs."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security Groups do banco."
}

variable "instance_class" {
  type        = string
  description = "Classe RDS."
  default     = "db.t3.micro"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente."
}
