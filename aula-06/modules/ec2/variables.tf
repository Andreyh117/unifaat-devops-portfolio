variable "instance_name" {
  type        = string
  description = "Nome da instância."
}

variable "instance_type" {
  type        = string
  description = "Tipo EC2."
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI da instância."
}

variable "subnet_id" {
  type        = string
  description = "ID da subnet."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security Groups da instância."
}

variable "key_name" {
  type        = string
  description = "Key Pair existente na região."
}

variable "user_data" {
  type        = string
  description = "Script de inicialização opcional."
  default     = null
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente."
}
