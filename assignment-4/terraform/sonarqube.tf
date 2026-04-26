resource "aws_security_group" "sonar_sg" {
  name   = "sonarqube-sg"
  vpc_id = aws_vpc.main.id        # resource, not data source

  ingress {
    description = "SonarQube UI from my IP"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description     = "SonarQube from Jenkins agent"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_agent_sg.id]
  }

  ingress {
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

  tags = { Name = "sonarqube-sg" }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.sonar_sg.id]
  key_name               = aws_key_pair.assign4_key.key_name

  user_data = <<-USERDATA
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io docker-compose
    systemctl enable docker && systemctl start docker
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    mkdir -p /opt/sonarqube
    cat > /opt/sonarqube/docker-compose.yml << 'COMPOSE'
version: '3'
services:
  sonarqube:
    image: sonarqube:community
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonar_data:/opt/sonarqube/data
      - sonar_logs:/opt/sonarqube/logs
volumes:
  sonar_data:
  sonar_logs:
COMPOSE
    cd /opt/sonarqube && docker-compose up -d
  USERDATA

  tags = { Name = "sonarqube-server" }
}
