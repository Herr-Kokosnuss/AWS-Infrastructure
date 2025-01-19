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




