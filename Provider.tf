# Terraform and provider configuration
#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
  required_version = ">=1.0.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = aws_eks_cluster.cocoplanner.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cocoplanner.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cocoplanner.name]
    command     = "aws"
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cocoplanner.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cocoplanner.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cocoplanner.name]
      command     = "aws"
    }
  }
}