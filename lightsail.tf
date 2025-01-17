# Create Lightsail Instance for WordPress
resource "aws_lightsail_instance" "wordpress" {
  name              = "wordpress-instance"
  availability_zone = "us-east-1a"
  blueprint_id      = "wordpress"
  bundle_id         = "micro_3_0"
  key_pair_name     = aws_lightsail_key_pair.wordpress_key.name

  tags = {
    Name = "Cocolancer.com"
  }
}

# Create static IP for the instance
resource "aws_lightsail_static_ip" "wordpress" {
  name = "wordpress-static-ip"
}

# Attach static IP to the instance
resource "aws_lightsail_static_ip_attachment" "wordpress" {
  static_ip_name = aws_lightsail_static_ip.wordpress.name
  instance_name  = aws_lightsail_instance.wordpress.name
}

# Open required ports
resource "aws_lightsail_instance_public_ports" "wordpress" {
  instance_name = aws_lightsail_instance.wordpress.name

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
  }

} 