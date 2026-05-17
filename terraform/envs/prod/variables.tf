variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "demo-app"
}

variable "app_env" {
  description = "APP_ENV passed to app"
  type        = string
  default     = "dev"
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "debug"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "password123"
}
variable "image_repository" {
  description = "Container image repository"
  type        = string
  default     = "demo-app"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "tf-v1"
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
  default     = "Never"
}

variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "service_type" {
  description = "Kubernetes Service type"
  type        = string
  default     = "NodePort"
}

variable "service_port" {
  description = "Kubernetes Service port"
  type        = number
  default     = 80
}
