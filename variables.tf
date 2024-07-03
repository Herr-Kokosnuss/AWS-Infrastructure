# creating ami variable
variable "ami" {
  default     = "ami-01b799c439fd5516a"
  description = "value of the ami"
  #type = string # we can remove default and add type. this will prompt the user to enter the value of the variable in the terminal. 
}

# look up the subnets within VPC.
data "aws_vpc" "main" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# variable "default_vpc_id" {
#   description = "The ID of the default VPC"
#   type        = string
# }

# variable "default_subnet_ids" {
#   description = "The IDs of the default subnets"
#   type        = list(string)
# }
