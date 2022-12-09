#apache-security group
resource "aws_security_group" "H-grafana-sg" {
  name        = "H-grafana-sg"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.H-vpc.id

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.77.103/32"]
  }
  ingress {
    description = "this is inbound rule"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "this is inbound rule"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "this is inbound rule"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.H-bastion-sg.id}"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "H-grafana"
  }
}
#apacheuserdata
data "template_file" "grafanauser" {
  template = file("grafana.sh")

}
# apache instance
resource "aws_instance" "H-grafana" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.H-privatesubnet[2].id
  vpc_security_group_ids = [aws_security_group.H-grafana-sg.id]
  key_name               = aws_key_pair.master.id
  user_data              = data.template_file.grafanauser.rendered
  tags = {
    Name = "H-grafana"
  }
}

# alb target-group
resource "aws_lb_target_group" "H-grafana-tg" {
  name     = "H-grafana-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-grafana-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-grafana-tg.arn
  target_id        = aws_instance.H-grafana.id
  port             = 3000
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-grafana-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-grafana-tg.arn
  }

  condition {
    host_header {
      values = ["hs.grafana.quest"]
    }
  }
}


# alb target-group
resource "aws_lb_target_group" "H-prometheus-tg" {
  name     = "H-prometheus-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-prometheus-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-prometheus-tg.arn
  target_id        = aws_instance.H-grafana.id
  port             = 9090
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-prometheus-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-prometheus-tg.arn
  }

  condition {
    host_header {
      values = ["hs.prometheus.quest"]
    }
  }
}

