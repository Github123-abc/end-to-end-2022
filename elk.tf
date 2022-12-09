#security_group
resource "aws_security_group" "H-elk-sg" {
  name        = "H-elk-sg"
  description = "Allow  inbound traffic"
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
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "admin"
    from_port   = 9200
    to_port     = 9200
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
    Name = "H-elk-sg"
  }
}
data "template_file" "elkuser" {
  template = file("elk.sh")

}

#instance
resource "aws_instance" "H-elk" {
  ami           = var.ami_ubuntu
  instance_type = var.type
  subnet_id     = aws_subnet.H-privatesubnet[2].id
  # availability_zone = data.aws_availability_zones.available.names[0]
  key_name               = aws_key_pair.master.id
  vpc_security_group_ids = [aws_security_group.H-elk-sg.id]
  user_data              = data.template_file.elkuser.rendered

  tags = {
    Name = "H-elk"
  }
}



# alb target-group
resource "aws_lb_target_group" "H-elk-tg" {
  name     = "H-elk-tg"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-elk-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-elk-tg.arn
  target_id        = aws_instance.H-elk.id
  port             = 9200
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-elk-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-elk-tg.arn
  }

  condition {
    host_header {
      values = ["hs.elk.quest"]
    }
  }
}