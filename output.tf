output "Load_Balancer_DNS" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "Default_VPC_ID" {
  value       = data.aws_vpc.main.id
  description = "The ID of the default VPC"
}

# # Output the IDs of all subnets in the default VPC
# output "default_vpc_subnet_ids" {
#   value       = data.aws_subnets.default.ids
#   description = "The IDs of all subnets within the default VPC"
# }

# output "EIP_Main_Instance" {
#   value       = aws_eip.ElasticIP.public_ip
#   description = "The public IP address of the Elastic IP"
# }

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}