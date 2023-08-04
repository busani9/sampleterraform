resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.terraform-key-pair}"
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" { # Generate "${var.terraform-key-pair}.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./${var.terraform-key-pair}.pem
      chmod 400 ./${var.terraform-key-pair}.pem
    EOT
  }

}


resource "aws_instance" "dev" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.dev-sg.id}"]
  key_name                    = "${var.terraform-key-pair}"
  associate_public_ip_address = true
depends_on = [aws_key_pair.generated_key]
  tags = {
    Name = "${var.tag}-ec2"
  }
}

  
