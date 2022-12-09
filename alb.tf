resource "aws_security_group" "H-alb-sg" {
  name        = "H-alb-sg"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.H-vpc.id

  #   ingress {
  #     description = "this is inbound rule"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_blocks = ["103.110.170.84/32"]
  #   }
  ingress {
    description = "this is inbound rule"
    from_port   = 80
    to_port     = 80
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
    Name = "H-alb-sg"
  }
}

resource "aws_lb" "H-alb" {
  name               = "H-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.H-alb-sg.id]
  subnets            = ["${aws_subnet.H-publicsubnet[1].id}", "${aws_subnet.H-publicsubnet[2].id}"]

  #   enable_deletion_protection = true

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
    Environment = "H-alb"
  }
}


resource "aws_lb_listener" "H-alb-listener" {
  load_balancer_arn = aws_lb.H-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.H-jenkins-tg.arn
  }
}