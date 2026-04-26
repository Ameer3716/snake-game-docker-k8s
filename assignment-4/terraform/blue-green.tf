# ── ALB Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "alb_sg" {
  name   = "alb-blue-green-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-blue-green-sg" }
}

# ── ASG Instances Security Group ──────────────────────────────────────────────
resource "aws_security_group" "asg_sg" {
  name   = "asg-instances-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
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

  tags = { Name = "asg-instances-sg" }
}

# ── Application Load Balancer ─────────────────────────────────────────────────
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  tags = { Name = "web-alb" }
}

# ── Launch Template ───────────────────────────────────────────────────────────
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.assign4_key.key_name

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y && apt-get install -y nginx
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "<h1>Instance: $INSTANCE_ID</h1>" > /var/www/html/index.html
    echo '{"status":"ok"}' > /var/www/html/health
    systemctl enable nginx && systemctl start nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "asg-web-instance" }
  }
}

# ── Target Group: Blue ────────────────────────────────────────────────────────
resource "aws_lb_target_group" "blue" {
  name     = "tg-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
  }

  tags = { Name = "tg-blue" }
}

# ── Target Group: Green ───────────────────────────────────────────────────────
resource "aws_lb_target_group" "green" {
  name     = "tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
  }

  tags = { Name = "tg-green" }
}

# ── ASG Blue ──────────────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "blue" {
  name                = "asg-blue"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.blue.arn]

  tag {
    key                 = "Name"
    value               = "asg-blue-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Color"
    value               = "blue"
    propagate_at_launch = true
  }
}

# ── ASG Green ─────────────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "green" {
  name                = "asg-green"
  min_size            = 0
  max_size            = 3
  desired_capacity    = 0
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.green.arn]

  tag {
    key                 = "Name"
    value               = "asg-green-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Color"
    value               = "green"
    propagate_at_launch = true
  }
}

# ── ALB Listeners ─────────────────────────────────────────────────────────────
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_listener" "smoke" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}
