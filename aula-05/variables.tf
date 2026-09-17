variable "region" {
  type    = string
  default = "us-east-1"
}
variable "public_key_path" {
  type    = string
  default = "~/.ssh/technova-key.pub"
}

variable "db_name" {
  type    = string
  default = "technova"
}
variable "db_username" {
  type    = string
  default = "technova_admin"
}
variable "db_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "A senha precisa ter pelo menos 8 caracteres."
  }
}
