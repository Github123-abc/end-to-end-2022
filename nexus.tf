#apache-security group
resource "aws_security_group" "H-nexus-sg" {
  name        = "H-nexus-sg"
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
    description     = "this is inbound rule"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.H-bastion-sg.id}"]
  }
  ingress {
    description = "this is inbound rule"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "nexus"
  }
}
#apacheuserdata
data "template_file" "nexususer" {
  template = file("nexus.sh")

}
# apache instance
resource "aws_instance" "H-nexus" {
  ami                    = var.ami
  instance_type          = var.type_small
  subnet_id              = aws_subnet.H-privatesubnet[2].id
  vpc_security_group_ids = [aws_security_group.H-nexus-sg.id]
  key_name               = aws_key_pair.master.id
  user_data              = data.template_file.nexususer.rendered
  tags = {
    Name = "H-nexus"
  }
}

# alb target-group
resource "aws_lb_target_group" "H-nexus-tg" {
  name     = "H-nexus-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-nexus-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-nexus-tg.arn
  target_id        = aws_instance.H-nexus.id
  port             = 8081
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-nexus-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-nexus-tg.arn
  }

  condition {
    host_header {
      values = ["hs.nexus.quest"]
    }
  }
}
