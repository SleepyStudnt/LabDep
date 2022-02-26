resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = file("deployer.pub")
}

resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
  description = "Allow SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}


resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-03d5c68bab01f3496"
  user_data     = base64encode(file("install.sh"))
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }
  
  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  provisioner "file" {
    source      = "source/connection.ovpn" 
    destination = "connect.ovpn"
  
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("deployer")
      host        = self.public_ip
    }
  }
}


