variable "ra" {
  description = "RA do aluno"
  type        = string
  default     = "6325231"
}

variable "aluno" {
  description = "Nome do aluno"
  type        = string
  default     = "Andreyh Rodrigues de Souza"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "TechNova"
}

variable "environment" {
  description = "Ambiente identificado nas tags dos recursos"
  type        = string
  default     = "development"
}
