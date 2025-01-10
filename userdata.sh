#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Install necessary packages
sudo yum update -y
sudo yum install -y amazon-efs-utils docker wget ca-certificates

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install GoTTY directly from release
wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
tar -xzf gotty_linux_amd64.tar.gz
sudo mv gotty /usr/local/bin/
sudo chmod +x /usr/local/bin/gotty

# Configure AWS ECR authentication
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 730335255832.dkr.ecr.us-east-1.amazonaws.com

# Pull the Docker image
docker pull 730335255832.dkr.ecr.us-east-1.amazonaws.com/trip-planner5:latest

# Create a startup script for GoTTY
cat <<EOF > /home/ec2-user/start-gotty.sh
#!/bin/bash
gotty -w -p 8080 docker run -it --rm \
  -v /etc/ssl/certs:/etc/ssl/certs:ro \
  -e SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
  -e REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
  -e CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
  730335255832.dkr.ecr.us-east-1.amazonaws.com/trip-planner5:latest
EOF

chmod +x /home/ec2-user/start-gotty.sh

# Create systemd service for GoTTY
cat <<EOF > /etc/systemd/system/gotty.service
[Unit]
Description=GoTTY Service
After=network.target docker.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/home/ec2-user/start-gotty.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start and enable GoTTY service
sudo systemctl daemon-reload
sudo systemctl start gotty
sudo systemctl enable gotty

echo "User data script execution completed"
