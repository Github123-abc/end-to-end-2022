#security_group
resource "aws_security_group" "H-filebit-sg" {
  name        = "H-filebit-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.H-vpc.id

  ingress {
    description = "admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.77.103/32"]
  }
  ingress {
    description     = "admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.H-bastion-sg.id}"]
  }

  ingress {
    description = "admin"
    from_port   = 8080
    to_port     = 8080
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
    Name = "filebit-sg"
  }
}
data "template_file" "filebituser" {
  template = file("filebit.sh")

}
#instance
resource "aws_instance" "H-filebit" {
  ami           = var.ami_ubuntu
  instance_type = var.type
  subnet_id     = aws_subnet.H-privatesubnet[2].id
  # availability_zone = data.aws_availability_zones.available.names[0]
  key_name               = aws_key_pair.master.id
  vpc_security_group_ids = [aws_security_group.H-filebit-sg.id]
  user_data              = data.template_file.filebituser.rendered

  tags = {
    Name = "H-filebit"
  }
}



# alb target-group
resource "aws_lb_target_group" "H-filebit-tg" {
  name     = "H-filebit-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-filebit-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-filebit-tg.arn
  target_id        = aws_instance.H-filebit.id
  port             = 8080
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-filebit-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-filebit-tg.arn
  }

  condition {
    host_header {
      values = ["hs.filebit.quest"]
    }
  }
}
