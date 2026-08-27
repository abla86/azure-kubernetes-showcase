variable "resource_group_name" {
  description = "Azure resource group."
  type        = string
  default     = "rg-azure-kubernetes-showcase"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "norwayeast"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Set null to use the supported default."
  type        = string
  default     = null
  nullable    = true
}

variable "node_count" {
  description = "Initial AKS system node count."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "AKS system node VM size."
  type        = string
  default     = "Standard_D2s_v5"
}
