# Create EFS File System
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs"
  encrypted      = true

  tags = {
    Name = "MyEFS"
  }
}

# Create EFS Mount Targets
resource "aws_efs_mount_target" "example" {
  count           = length(aws_subnet.public)
  subnet_id       = aws_subnet.public[count.index].id
  file_system_id  = aws_efs_file_system.example.id
  security_groups = [aws_security_group.efs.id]
} 