resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev"
  }
}


resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "devpublic"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "devprivate"
  }
}

resource "aws_internet_gateway" "devgw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "devgw"
  }
}



resource "aws_eip" "devnat-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.devgw]
}




resource "aws_nat_gateway" "devngw" {
  allocation_id = aws_eip.devnat-eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "devngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.devgw]
}


resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.dev.default_route_table_id

  tags = {
    Name = "dev-default-RT"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devgw.id
  }
}


resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.dev.id

  route = []

  tags = {
    Name = "Private-RT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rt.id
}


resource "aws_route" "private" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.devngw.id
}

resource "aws_security_group" "dev-sg" {
  name   = "dev-sg"
  vpc_id = aws_vpc.dev.id

  ingress {
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
    Name = "dev-sg"
  }
}



