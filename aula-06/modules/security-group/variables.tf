variable "name" {
  type        = string
  description = "Nome do Security Group."
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC."
}

variable "ingress_rules" {
  type        = list(object({ from_port = number, to_port = number, protocol = string, description = string, cidr_blocks = optional(list(string), []), security_groups = optional(list(string), []) }))
  description = "Regras de entrada por CIDR ou Security Group de origem."
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente."
}
