
resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-key-pair"
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" { # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./terraform-key-pair.pem
      chmod 400 ./terraform-key-pair.pem
    EOT
  }

}


resource "aws_instance" "dev" {
  ami                         = "ami-08df646e18b182346"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.dev-sg.id}"]
  key_name                    = "terraform-key-pair"
  associate_public_ip_address = true
  tags = {
    Name = "dev"
  }
}


