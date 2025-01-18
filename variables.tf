variable "ami" {
  description = "Value of the AMI"
  type        = string
  default     = "ami-01b799c439fd5516a" # Amazon Linux 2 x86_64 AMI
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"] # Update these to match your region
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# variable "private_subnet_cidrs" {
#   description = "CIDR blocks for the private subnets"
#   type        = list(string)
#   default     = ["10.0.3.0/24", "10.0.4.0/24"]
# }



# variable "db_username" {
#   description = "The username for the database"
#   type        = string
#   sensitive   = true
# }

# variable "db_password" {
#   description = "The password for the database"
#   type        = string
#   sensitive   = true
# }

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
