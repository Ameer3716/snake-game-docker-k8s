output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP of the instance (if in public subnet)"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP of the instance"
}

output "instance_id" {
  value       = aws_instance.this.id
  description = "Instance ID"
}
