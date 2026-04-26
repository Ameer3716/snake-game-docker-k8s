# ── VPC Outputs ───────────────────────────────────────────────────────────────
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

# ── Key Pair Outputs ──────────────────────────────────────────────────────────
output "key_name" {
  value = aws_key_pair.assign4_key.key_name
}

output "pem_file_path" {
  value = "${path.module}/assign4-devops-key.pem"
}

# ── AMI / Account Outputs ─────────────────────────────────────────────────────
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# ── Jenkins Outputs ───────────────────────────────────────────────────────────
output "jenkins_controller_ip" {
  value = aws_instance.jenkins_controller.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}

output "jenkins_initial_password_cmd" {
  value = "ssh -i assign4-devops-key.pem ubuntu@${aws_instance.jenkins_controller.public_ip} sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

output "jenkins_agent_private_ip" {
  value = aws_instance.jenkins_agent.private_ip
}

# ── SonarQube Output ──────────────────────────────────────────────────────────
output "sonarqube_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}

# ── ALB / Blue-Green Outputs ──────────────────────────────────────────────────
output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.web_alb.arn
}

output "tg_blue_arn" {
  value = aws_lb_target_group.blue.arn
}

output "tg_green_arn" {
  value = aws_lb_target_group.green.arn
}

output "listener_arn" {
  value = aws_lb_listener.main.arn
}

output "smoke_listener_arn" {
  value = aws_lb_listener.smoke.arn
}
