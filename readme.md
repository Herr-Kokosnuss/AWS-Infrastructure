# Cocoplanner - Cloud Infrastructure Project

## Project Overview
Cocoplanner is a containerized application deployed on **AWS** using **Infrastructure as Code (IaC)** with **Terraform**. The infrastructure is designed to be **highly available**, **scalable**, and **secure**, utilizing various AWS services and modern DevOps practices.

---

## Key Features

### 1. Infrastructure Components
- **VPC Configuration:** Custom VPC with public subnets across multiple availability zones.
- **Auto Scaling Group (ASG):** Ensures high availability and automatic scaling of EC2 instances.
- **Application Load Balancer (ALB):** Distributes traffic across instances.
- **Amazon EFS:** Provides shared file storage.
- **Security Groups:** Manages access control and network security.
- **IAM Roles:** Handles AWS service permissions.
- **Amazon ECR:** Stores Docker container images.

### 2. CI/CD Pipeline
- **GitHub Actions:** Workflow for automated container builds and deployments.
- Automatic **ECR push** on commits to the deployment branch.
- **Automated instance refresh** after new deployments.

### 3. Application Deployment
- **Containerized application:** Uses Docker.
- **GoTTY integration:** Enables web-based terminal access.
- **Systemd service:** Ensures automatic application startup.
- **AWS ECR:** Serves as the container registry.

### 4. Security Features
- **RSA key pair management:** Provides secure instance access.
- **Custom security groups:** Ensures network isolation.
- **IAM roles:** Facilitates secure service-to-service communication.

---

## Technical Stack
- **Infrastructure:** Terraform.
- **Cloud Provider:** AWS.
- **Container Runtime:** Docker.
- **CI/CD:** GitHub Actions.
- **Terminal Access:** GoTTY.
- **Monitoring:** AWS CloudWatch.

---

## Architecture
The application runs on **EC2 instances** within an **Auto Scaling Group**, with traffic distributed through an **Application Load Balancer**.  
The infrastructure spans **multiple availability zones** for high availability.  
**Docker containers** are pulled from **ECR**, and the application is exposed via **GoTTY** on port 8080.

---

## Deployment Process
1. **Infrastructure provisioning:** Managed using Terraform.
2. **Docker image builds:** Handled by GitHub Actions and pushed to ECR.
3. **Instance launch:** EC2 instances automatically pull the latest Docker image.
4. **Scaling and health:** Auto Scaling Group maintains desired capacity and health.
5. **Application access:** Available through the Application Load Balancer.

---

## Security Considerations
- **Private key management:** Securely generated and managed through Terraform.
- **Secure Docker image storage:** Private ECR repository.
- **Network isolation:** Achieved via security groups.
- **Encrypted communication:** Ensures data security using TLS.

---

## Monitoring and Maintenance
- **CloudWatch integration:** Provides robust monitoring.
- **Auto Scaling:** Dynamically handles load variations.
- **Automated instance refresh:** Keeps instances updated.
- **User data script logging:** Tracks execution for debugging and maintenance.

---

## Conclusion
This project demonstrates a **production-grade infrastructure setup** using modern cloud practices and tools. It is optimized for hosting **containerized applications** with **high availability**, **scalability**, and **security** requirements.
