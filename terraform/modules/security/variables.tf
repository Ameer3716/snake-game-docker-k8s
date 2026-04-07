variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "my_ip" {
  type        = string
  description = "Your public IP for SSH access"
}
