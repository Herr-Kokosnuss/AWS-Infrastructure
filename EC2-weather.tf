# Create Elastic IP for Weather Instance
resource "aws_eip" "weather" {
  domain = "vpc"
  tags = {
    Name = "weather-eip"
  }
}

# Create EC2 instance for Weather Application
resource "aws_instance" "weather" {
  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = aws_key_pair.main_key.key_name
  
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = base64encode(file("userdata-weather.sh"))

  tags = {
    Name = "weather-instance"
  }
}

# Associate Elastic IP with Weather Instance
resource "aws_eip_association" "weather" {
  instance_id   = aws_instance.weather.id
  allocation_id = aws_eip.weather.id
}

# Add outputs for Weather Instance
output "weather_instance_id" {
  description = "ID of the Weather EC2 instance"
  value       = aws_instance.weather.id
}

output "weather_instance_public_ip" {
  description = "Public IP of the Weather EC2 instance"
  value       = aws_eip.weather.public_ip
} 