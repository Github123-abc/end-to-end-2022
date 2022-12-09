#apache-security group
resource "aws_security_group" "H-jenkins-sg" {
  name        = "H-jenkins-sg"
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "this is inbound rule"
    from_port   = 9100
    to_port     = 9100
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
    Name = "H-jenkins-sg"
  }
}
#apacheuserdata
data "template_file" "jenkinsuser" {
  template = file("jenkins.sh")

}
# apache instance
resource "aws_instance" "H-jenkins" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.H-privatesubnet[2].id
  vpc_security_group_ids = [aws_security_group.H-jenkins-sg.id]
  key_name               = aws_key_pair.master.id
  user_data              = data.template_file.jenkinsuser.rendered
  tags = {
    Name = "H-jenkins"
  }
}

# alb target-group
resource "aws_lb_target_group" "H-jenkins-tg" {
  name     = "tg-jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "jenkins-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-jenkins-tg.arn
  target_id        = aws_instance.H-jenkins.id
  port             = 8080
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-jenkins-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-jenkins-tg.arn
  }

  condition {
    host_header {
      values = ["hs.jenkins.quest"]
    }
  }
}


# alb target-group
resource "aws_lb_target_group" "H-node-tg" {
  name     = "node-tg"
  port     = 9100
  protocol = "HTTP"
  vpc_id   = aws_vpc.H-vpc.id
}

resource "aws_lb_target_group_attachment" "H-node-tg-attachment" {
  target_group_arn = aws_lb_target_group.H-node-tg.arn
  target_id        = aws_instance.H-jenkins.id
  port             = 9100
}



# alb-listner_rule
resource "aws_lb_listener_rule" "H-node-hostbased" {
  listener_arn = aws_lb_listener.H-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-node-tg.arn
  }

  condition {
    host_header {
      values = ["hs.node.quest"]
    }
  }
}
