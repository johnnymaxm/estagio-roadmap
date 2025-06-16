variable "users" {
  description = "Configuração dos usuários IAM"
  type        = any
  default     = {}
}

variable "groups" {
  description = "Configuração dos grupos IAM"
  type        = any
  default     = {}
}

variable "policies" {
  description = "Configuração das políticas IAM"
  type        = any
  default     = {}
}