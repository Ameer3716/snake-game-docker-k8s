resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-controller-sg"
  vpc_id = aws_vpc.main.id        # resource, not data source

  ingress {
    description = "Jenkins UI from my IP only"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-controller-sg" }
}

resource "aws_instance" "jenkins_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.assign4_key.key_name

  user_data = <<-USERDATA
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y openjdk-17-jdk curl wget gnupg2 software-properties-common unzip

    # Jenkins LTS
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
      tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/" | \
      tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update -y && apt-get install -y jenkins
    systemctl enable jenkins && systemctl start jenkins

    # Git
    apt-get install -y git

    # Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker jenkins
    usermod -aG docker ubuntu
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

    echo "Jenkins setup done" > /tmp/jenkins-done.txt
  USERDATA

  tags = { Name = "jenkins-controller" }
}
