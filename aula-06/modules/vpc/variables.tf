variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC."
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente."
}

variable "subnets" {
  type        = map(object({ cidr = string, az = string, type = string }))
  description = "Subnets com CIDR, zona e tipo public ou private."
}
