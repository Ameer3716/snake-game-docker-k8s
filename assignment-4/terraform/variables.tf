variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Your public IP with /32 for SSH/Jenkins access"
  type        = string
  default     = "0.0.0.0/0"   # Overridden in terraform.tfvars
}
