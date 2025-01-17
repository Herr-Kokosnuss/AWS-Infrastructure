# Create RSA key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# EC2 Key Pair
resource "aws_key_pair" "main_key" {
  key_name   = "keykey"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Save EC2 private key
resource "local_file" "main_key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "keykey"
  file_permission = "0400"
}

# Lightsail Key Pair
resource "aws_lightsail_key_pair" "wordpress_key" {
  name       = "wordpress-lightsail-key"
  public_key = tls_private_key.rsa.public_key_openssh
}