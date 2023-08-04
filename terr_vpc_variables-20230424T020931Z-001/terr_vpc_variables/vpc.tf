resource "aws_vpc" "dev" {
  cidr_block       = "${var.cidr_block}"
  instance_tenancy = "default"

  tags = {
    Name = "${var.tag}-vpc"
  }
}


resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "${var.subnet1_cidr_block}"
  availability_zone = "${var.availability_zone}"
  tags = {
    Name = "${var.tag}-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "${var.subnet2_cidr_block}"

  tags = {
    Name = "${var.tag}-private"
  }
}

resource "aws_internet_gateway" "devgw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.tag}-gw"
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
    Name = "${var.tag}-ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.devgw]
}


resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.dev.default_route_table_id

  tags = {
    Name = "${var.tag}-default-RT"
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
    Name = "${var.tag}-Private-RT"
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
  name   = "${var.tag}-sg"
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
    Name = "${var.tag}-sg"
  }
}

