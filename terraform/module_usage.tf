# ═══════════════════════════════════════════════════════════════════════════════
# TASK 6: TERRAFORM MODULES USAGE
# ═══════════════════════════════════════════════════════════════════════════════
# This file demonstrates how to use the reusable modules for VPC, Security, and Compute

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  environment          = "prod"
  aws_region           = var.aws_region
}

module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = "prod"
  my_ip       = var.my_ip != "" ? var.my_ip : "0.0.0.0/32"
}

module "compute" {
  source             = "./modules/compute"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security.web_sg_id]
  key_name           = aws_key_pair.devops_key.key_name
  environment        = "prod"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TASK 6 MODULE OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "module_vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID from module"
}

output "module_public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs from module"
}

output "module_web_sg_id" {
  value       = module.security.web_sg_id
  description = "Web security group ID from module"
}

output "module_web_public_ip" {
  value       = module.compute.public_ip
  description = "Public IP of compute instance from module"
}

output "module_web_instance_id" {
  value       = module.compute.instance_id
  description = "Instance ID of compute instance from module"
}
