# Jenkins Setup Guide

## Controller
- Instance: t3.medium, Ubuntu 22.04, public subnet
- Port 8080 open to admin IP only, port 22 for SSH
- Installed via user_data: Java 17, Jenkins LTS, Git, Docker, AWS CLI, Terraform, Trivy, tfsec

## Agent
- Instance: t3.medium, Ubuntu 22.04, PRIVATE subnet
- SSH access only from controller security group
- IAM role attached for ECR/S3 access (no long-lived keys)
- Label: linux-agent

## Connection
- Controller generates RSA keypair, public key added to agent's jenkins user authorized_keys
- Jenkins → Manage Nodes → SSH launcher