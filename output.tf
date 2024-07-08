output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "default_vpc_id" {
  value       = data.aws_vpc.main.id
  description = "The ID of the default VPC"
}

# Output the IDs of all subnets in the default VPC
output "default_vpc_subnet_ids" {
  value       = data.aws_subnets.default.ids
  description = "The IDs of all subnets within the default VPC"
}

output "EIP" {
  value       = aws_eip.ElasticIP.public_ip
  description = "The public IP address of the Elastic IP"
}