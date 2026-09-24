variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC."
}

variable "subnets" {
  type        = map(object({ cidr = string, az = string, type = string }))
  description = "Subnets de cada ambiente."
}

variable "key_name" {
  type        = string
  description = "Key Pair existente em us-east-1."
  default     = "vockey"
}

variable "db_name" {
  type        = string
  description = "Nome do database."
}

variable "db_username" {
  type        = string
  description = "Usuário administrador PostgreSQL."
  default     = "technova_admin"
}

variable "db_password" {
  type        = string
  description = "Senha sensível fornecida via TF_VAR_db_password."
  sensitive   = true
}
