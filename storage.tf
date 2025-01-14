# Create EFS File System
resource "aws_efs_file_system" "Cocoplanner" {
  creation_token = "my-efs"
  encrypted      = true

  tags = {
    Name = "Cocoplanner"
  }
}

# Create EFS Mount Targets
resource "aws_efs_mount_target" "Cocoplanner" {
  count           = length(aws_subnet.public)
  subnet_id       = aws_subnet.public[count.index].id
  file_system_id  = aws_efs_file_system.Cocoplanner.id
  security_groups = [aws_security_group.efs.id]
} 