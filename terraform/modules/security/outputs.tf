output "web_sg_id" {
  value       = aws_security_group.web.id
  description = "Security group ID for web servers"
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "Security group ID for database servers"
}
