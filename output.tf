output "Load_Balancer_DNS" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}
output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "The name of the Auto Scaling Group"
}
output "ASG_instance_public_ips" {
  description = "Public IP addresses of instances in the ASG"
  value       = data.aws_instances.asg_instances.public_ips
}
output "ASG_instance_ids" {
  description = "Instance IDs of instances in the ASG"
  value       = data.aws_instances.asg_instances.ids
}

output "efs_id" {
  description = "ID of the Elastic File System"
  value       = aws_efs_file_system.example.id
}

output "grafana_cloudwatch_secret_access_key" {
  value     = aws_iam_access_key.grafana_cloudwatch.secret
  sensitive = true
}
output "grafana_cloudwatch_access_key_id" {
  value = aws_iam_access_key.grafana_cloudwatch.id
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
# output "Default_VPC_ID" {
#   value       = data.aws_vpc.main.id
#   description = "The ID of the default VPC"
# }

# # Output the IDs of all subnets in the default VPC
# output "default_vpc_subnet_ids" {
#   value       = data.aws_subnets.default.ids
#   description = "The IDs of all subnets within the default VPC"
# }

# output "EIP_Main_Instance" {
#   value       = aws_eip.ElasticIP.public_ip
#   description = "The public IP address of the Elastic IP"
# }

# output "s3_bucket_arn" {
#   value       = aws_s3_bucket.terraform_state.arn
#   description = "The ARN of the S3 bucket"
# }
# output "dynamodb_table_name" {
#   value       = aws_dynamodb_table.terraform_locks.name
#   description = "The name of the DynamoDB table"
# }

# output "address" {
# value = aws_db_instance.example.address
# description = "Connect to the database at this endpoint"
# }

# output "port" {
# value = aws_db_instance.example.port
# description = "The port the database is listening on"
# }




