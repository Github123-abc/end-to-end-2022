# bastion - security group
resource "aws_security_group" "H-bastion-sg" {
  name        = "H-bastion-sg"
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "H-bastion"
  }
}
# bastion instance
resource "aws_instance" "H-bastion" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.H-publicsubnet[0].id
  vpc_security_group_ids = [aws_security_group.H-bastion-sg.id]
  key_name               = aws_key_pair.master.id
  tags = {
    Name = "H-bastion"
  }
}