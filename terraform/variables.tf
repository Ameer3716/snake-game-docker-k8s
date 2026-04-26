variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "instance_type must be one of: t3.micro, t3.small, t3.medium."
  }
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI (us-east-1)"
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  default = "devops-key"
}

variable "my_ip" {
  description = "Your public IP for SSH access (e.g. 1.2.3.4/32)"
  type        = string
  default     = ""
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 2
}
