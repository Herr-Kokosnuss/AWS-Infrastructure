# Cocoplanner - Cloud Infrastructure Project

---
> **❗ IMPORTANT: This repository consists of two branches:**
> - `prod`: Contains the original ASG-based infrastructure
> - `prod-k8`: Contains the Kubernetes-based infrastructure

---
## Project Overview
Cocoplanner is a containerized application deployed on **AWS** using **Infrastructure as Code (IaC)** with **Terraform**. The infrastructure is designed to be **highly available**, **scalable**, and **secure**, utilizing various AWS services and modern DevOps practices.

---

## Key Features

### 1. Infrastructure Components
- **VPC Configuration:** Custom VPC with public subnets across multiple availability zones
- **Amazon EKS:** Managed Kubernetes cluster for container orchestration
- **Node Groups:** Auto-scaling worker nodes for the Kubernetes cluster
- **Amazon EFS:** Provides shared file storage
- **Security Groups:** Manages access control and network security
- **IAM Roles:** Handles AWS service permissions
- **Amazon ECR:** Stores Docker container images

### 2. CI/CD Pipeline
- **GitHub Actions:** Workflow for automated container builds and deployments
- Automatic **ECR push** on commits to the deployment branch
- **Kubernetes Deployments:** Handles rolling updates of application pods

### 3. Application Deployment
- **Containerized application:** Uses Docker
- **Kubernetes Services:** Load balancing and service discovery
- **Kubernetes Secrets:** Secure management of application secrets
- **AWS ECR:** Container registry for Docker images

### 4. Security Features
- **RSA key pair management:** Provides secure node access
- **Custom security groups:** Ensures network isolation
- **IAM roles:** Facilitates secure service-to-service communication

---

## Technical Stack
- **Infrastructure:** Terraform
- **Cloud Provider:** AWS
- **Container Orchestration:** Kubernetes (EKS)
- **Container Runtime:** Docker
- **CI/CD:** GitHub Actions
- **Monitoring:** AWS CloudWatch

---

## Architecture
The application runs on **Amazon EKS** with worker nodes managed by **Node Groups**.  
The infrastructure spans **multiple availability zones** for high availability.  
**Docker containers** are pulled from **ECR**, and the application is exposed via **Kubernetes Service** of type LoadBalancer.

---

## Deployment Process
1. **Infrastructure provisioning:** Managed using Terraform
2. **Docker image builds:** Handled by GitHub Actions and pushed to ECR
3. **Kubernetes deployment:** Pods are scheduled on worker nodes
4. **Scaling:** Handled by Kubernetes Horizontal Pod Autoscaling
5. **Application access:** Available through Kubernetes LoadBalancer Service

---

## Security Considerations
- **Private key management:** Securely generated and managed through Terraform
- **Secure Docker image storage:** Private ECR repository
- **Network isolation:** Achieved via security groups
- **Encrypted communication:** Ensures data security using TLS
- **Secret management:** Handled through Kubernetes Secrets

---

## Monitoring and Maintenance
- **CloudWatch integration:** Provides robust monitoring
- **Container Insights:** Detailed metrics for EKS cluster
- **Kubernetes health checks:** Liveness and readiness probes
- **Auto-scaling:** Dynamic scaling based on resource utilization

