# ═══════════════════════════════════════════════════════════════════════════════
# TASK 1 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  description = "List of private subnet IDs"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "The ID of the NAT Gateway"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TASK 2 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "web_server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the web server"
}

output "web_server_id" {
  value       = aws_instance.web_server.id
  description = "Instance ID of the web server"
}

output "db_server_private_ip" {
  value       = aws_instance.db_server.private_ip
  description = "Private IP of the database server"
}

output "db_server_id" {
  value       = aws_instance.db_server.id
  description = "Instance ID of the database server"
}

output "key_pair_name" {
  value       = aws_key_pair.devops_key.key_name
  description = "Name of the SSH key pair"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TASK 3 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "s3_bucket_name" {
  value       = aws_s3_bucket.tf_state.id
  description = "Name of the S3 bucket for Terraform state"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.tf_state.arn
  description = "ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Name of the DynamoDB table for state locking"
}

output "ec2_s3_role_name" {
  value       = aws_iam_role.ec2_s3_role.name
  description = "Name of the IAM role for EC2 S3 access"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TASK 4 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "asg_name" {
  value       = aws_autoscaling_group.web_asg.name
  description = "Name of the Auto Scaling Group"
}

output "asg_desired_capacity" {
  value       = aws_autoscaling_group.web_asg.desired_capacity
  description = "Desired capacity of the ASG"
}

output "cpu_high_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
  description = "Name of the CPU high alarm"
}

output "cpu_low_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
  description = "Name of the CPU low alarm"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TASK 5 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "alb_dns_name" {
  value       = aws_lb.web_alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_arn" {
  value       = aws_lb.web_alb.arn
  description = "ARN of the Application Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.web_tg.arn
  description = "ARN of the target group"
}
