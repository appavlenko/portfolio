resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "network"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-central-1b"

  tags = {
    Name = "Private-Subnet"
  }
}
