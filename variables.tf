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