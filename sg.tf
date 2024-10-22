######### Security Groups ######
# Creating a security group for the Application Load Balancer and EFS
resource "aws_security_group" "alb" {
  name = "terraform-example-alb-and-efs"

  # Existing wide-open ingress rule
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EFS-specific ingress rule
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your VPC CIDR
    description = "Allow inbound NFS traffic for EFS"
  }

  # Existing wide-open egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EFS-specific egress rule
  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your VPC CIDR
    description = "Allow outbound NFS traffic for EFS"
  }
}
#
# Creating a security group for the instance
# resource "aws_security_group" "test" {
#   name = "terraform-example-instance"
#   # ingress {
#   #   from_port   = 8080
#   #   to_port     = 8080
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }
#    ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Allow all outbound requests
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }
