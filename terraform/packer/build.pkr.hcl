# [Member 2] - Task 6: Configured Packer AMI Builder
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]   # Canonical
  }

  ami_name        = "devops-custom-nginx-{{timestamp}}"
  ami_description = "Custom Ubuntu AMI with Nginx, curl, and stress-ng pre-installed"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx curl stress-ng",
      "echo '<h1>Welcome to Custom Packer AMI</h1><p>This AMI was built with Packer and has Nginx pre-installed.</p>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable nginx"
    ]
  }
}
