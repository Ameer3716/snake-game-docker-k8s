resource "aws_security_group" "jenkins_agent_sg" {
  name   = "jenkins-agent-sg"
  vpc_id = aws_vpc.main.id        # resource, not data source

  ingress {
    description     = "SSH from Jenkins controller only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-agent-sg" }
}

resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_agent_policy" {
  name = "jenkins-agent-ecr-s3-policy"
  role = aws_iam_role.jenkins_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::devops-tf-state-*", "arn:aws:s3:::devops-tf-state-*/*"]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-instance-profile"
  role = aws_iam_role.jenkins_agent_role.name
}

resource "aws_instance" "jenkins_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  key_name               = aws_key_pair.assign4_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name

  user_data = <<-USERDATA
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y openjdk-17-jdk git curl wget unzip

    # Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl enable docker && systemctl start docker

    # AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip /tmp/awscliv2.zip -d /tmp/ && /tmp/aws/install

    # Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
      tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    apt-get update -y && apt-get install -y terraform

    # Trivy
    wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | \
      gpg --dearmor -o /usr/share/keyrings/trivy.gpg
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
      https://aquasecurity.github.io/trivy-repo/deb generic main" | \
      tee /etc/apt/sources.list.d/trivy.list > /dev/null
    apt-get update -y && apt-get install -y trivy

    # Create jenkins user for SSH agent connection
    useradd -m -s /bin/bash jenkins
    usermod -aG docker jenkins
    mkdir -p /home/jenkins/.ssh
    chmod 700 /home/jenkins/.ssh
    chown -R jenkins:jenkins /home/jenkins
  USERDATA

  tags = { Name = "jenkins-agent" }
}
