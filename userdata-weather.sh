#!/bin/bash

# Update and install dependencies
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create deployment directory
mkdir -p /app
cd /app

# Configure AWS CLI and login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 730335255832.dkr.ecr.us-east-1.amazonaws.com

# Pull config image and extract files
docker pull 730335255832.dkr.ecr.us-east-1.amazonaws.com/weather-config:latest
docker run --rm -v /app:/deployment 730335255832.dkr.ecr.us-east-1.amazonaws.com/weather-config:latest

# Pull service images
docker pull 730335255832.dkr.ecr.us-east-1.amazonaws.com/weather:latest
docker pull 730335255832.dkr.ecr.us-east-1.amazonaws.com/weather-api:latest
docker pull 730335255832.dkr.ecr.us-east-1.amazonaws.com/weather-frontend:latest

# Create a startup script that will be run manually after .env is uploaded
cat > /app/start-services.sh << 'EOF'
#!/bin/bash
cd /app

if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please upload the .env file to /app/.env first"
    exit 1
fi

# Start services
docker-compose up -d

echo "Services started successfully!"
EOF

chmod +x /app/start-services.sh

# Set permissions
chown -R ec2-user:ec2-user /app 