output "Load_Balancer_DNS" {
  value       = aws_lb.Cocoplanner.dns_name
  description = "The domain name of the load balancer"
}
output "asg_name" {
  value       = aws_autoscaling_group.Cocoplanner.name
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
  value       = aws_efs_file_system.Cocoplanner.id
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

#word press
output "wordpress_public_ip" {
  value       = aws_lightsail_static_ip.wordpress.ip_address
  description = "Public IP address of the WordPress instance"
}

# Output the automation credentials (github secrets)
output "github_actions_access_key_id" {
  value = aws_iam_access_key.github_actions_user.id
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions_user.secret
  sensitive = true
}

# EKS Cluster Outputs
output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.cocoplanner.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.cocoplanner.certificate_authority[0].data
  sensitive   = true
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cocoplanner.name
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.cocoplanner.vpc_config[0].cluster_security_group_id
}

output "eks_node_group_id" {
  description = "EKS Node Group ID"
  value       = aws_eks_node_group.cocoplanner.id
}

# Kubernetes Service Output
output "kubernetes_service_load_balancer_hostname" {
  description = "Hostname of the Kubernetes service load balancer"
  value       = kubernetes_service.cocoplanner.status[0].load_balancer[0].ingress[0].hostname
}




