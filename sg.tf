######### Security Groups ######
# Creating a security group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name = "terraform-example-alb-${terraform.workspace}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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
