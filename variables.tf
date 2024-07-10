locals {
  instance_name = "${terraform.workspace}-instance"

  ami_ids = {
    "default" = "ami-01b799c439fd5516a" # Fallback AMI
    "dev"     = "ami-01b799c439fd5516a" # Development AMI
    "prod"    = "ami-06c68f701d8090592" # Staging AMI
  }
}

variable "ami" {
  description = "Value of the AMI based on workspace"
  type        = string

}


locals {
  vpc_ids = {
    "dev"  = "vpc-00803c89e00c3a3a5"
    "prod" = "vpc-012320dbf1564c17a"
  }
}

data "aws_vpc" "main" {
  id = local.vpc_ids[terraform.workspace]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
















# # creating ami variable
# variable "ami" {
#   default     = "ami-01b799c439fd5516a"
#   description = "value of the ami"
#   #type = string # we can remove default and add type. this will prompt the user to enter the value of the variable in the terminal. 
# }

# # look up the subnets within VPC.
# data "aws_vpc" "main" {
#   default = true
# }
# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.main.id]
#   }
# }

# variable "default_vpc_id" {
#   description = "The ID of the default VPC"
#   type        = string
# }

# variable "default_subnet_ids" {
#   description = "The IDs of the default subnets"
#   type        = list(string)
# }
