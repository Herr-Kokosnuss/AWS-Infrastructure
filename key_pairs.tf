# creeating key-pair
resource "aws_key_pair" "main_key" {
  key_name = "keykey"
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "main_key" {
  content = tls_private_key.rsa.private_key_pem
  filename = "keykey"
  
}