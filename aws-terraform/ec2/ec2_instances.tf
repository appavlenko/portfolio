resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = "terraform-key"

  vpc_security_group_ids = [aws_security_group.main.id]
  associate_public_ip_address = true

  tags = {
    Name = "Web-Server"
  }
}

resource "aws_instance" "db" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = "terraform-key"

  vpc_security_group_ids = [aws_security_group.main.id]
  associate_public_ip_address = false

  tags = {
    Name = "DB-Server"
  }
}
