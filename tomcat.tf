#apache-security group
resource "aws_security_group" "H-tomcat-sg" {
  name        = "H-tomcat-sg"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.H-vpc.id

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.110.170.84/32"]
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
    Name = "H-tomcat-sg"
  }
}
#apacheuserdata
data "template_file" "tomcatuser" {
  template = file("tomcat.sh")

}
# apache instance
resource "aws_instance" "H-tomcat" {
  ami                    = var.ami_ubuntu
  instance_type          = var.type
  subnet_id              = aws_subnet.H-privatesubnet[0].id
  vpc_security_group_ids = [aws_security_group.H-tomcat-sg.id]
  key_name               = aws_key_pair.master.id
  user_data              = data.template_file.tomcatuser.rendered
  tags = {
    Name = "H-tomcat"
  }
}

resource "aws_lb_target_group" "H-tomcat-tg" {
  name     = "H-tomcat-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-tomcat-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-tomcat-tg.arn
  target_id        = aws_instance.H-tomcat.id
  port             = 8080
}

resource "aws_lb_listener_rule" "H-tomcat-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-tomcat-tg.arn
  }

  condition {
    host_header {
      values = ["hs.tomcat.quest"]
    }
  }
}
