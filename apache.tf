#apache-security group
resource "aws_security_group" "H-apache-sg" {
  name        = "H-apache-sg"
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "this is inbound rule"
    from_port   = 9000
    to_port     = 9000
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
    Name = "apache-sg"
  }
}
#apacheuserdata
data "template_file" "apacheuser" {
  template = file("apache.sh")

}
# apache instance
resource "aws_instance" "H-apache" {
  ami                    = var.ami_ubuntu
  instance_type          = var.type_biger
  subnet_id              = aws_subnet.H-privatesubnet[2].id
  vpc_security_group_ids = [aws_security_group.H-apache-sg.id]
  key_name               = aws_key_pair.master.id
  user_data              = data.template_file.apacheuser.rendered
  tags = {
    Name = "H-apache"
  }
}

# alb target-group
resource "aws_lb_target_group" "H-apache-tg" {
  name     = "tg-apache"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-apache-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-apache-tg.arn
  target_id        = aws_instance.H-apache.id
  port             = 80
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-apache-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-apache-tg.arn
  }

  condition {
    host_header {
      values = ["hs.apache.quest"]
    }
  }
}

# alb target-group
resource "aws_lb_target_group" "H-sonar-tg" {
  name     = "sonar-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-sonar-attachment" {
  target_group_arn = aws_lb_target_group.H-sonar-tg.arn
  target_id        = aws_instance.H-apache.id
  port             = 9000
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-sonar-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-sonar-tg.arn
  }

  condition {
    host_header {
      values = ["hs.sonar.quest"]
    }
  }
}
