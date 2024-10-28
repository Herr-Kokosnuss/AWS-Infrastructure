#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Install necessary packages
sudo yum update -y
sudo yum install -y amazon-efs-utils httpd

# Create mount directory
sudo mkdir -p /mnt/efs
echo "Mount directory created"

# Wait for EFS to be available
MAX_RETRIES=12
RETRY_INTERVAL=10
retry_count=0

while [ $retry_count -lt $MAX_RETRIES ]; do
    if sudo mount -t efs -o tls ${efs_id}:/ /mnt/efs; then
        echo "EFS mounted successfully"
        break
    else
        echo "EFS mount attempt $((retry_count + 1)) failed, retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
        retry_count=$((retry_count + 1))
    fi
done

if [ $retry_count -eq $MAX_RETRIES ]; then
    echo "Failed to mount EFS after $MAX_RETRIES attempts"
    exit 1
fi

# Verify mount
if mountpoint -q /mnt/efs; then
    echo "EFS is mounted at /mnt/efs"
else
    echo "EFS mount verification failed"
    exit 1
fi

# Add mount to fstab for persistence
echo "${efs_id}:/ /mnt/efs efs _netdev,tls,iam 0 0" | sudo tee -a /etc/fstab

# Set proper permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /mnt/efs
sudo chmod 2775 /mnt/efs
find /mnt/efs -type d -exec sudo chmod 2775 {} \;
find /mnt/efs -type f -exec sudo chmod 0664 {} \;

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Create symbolic link for the web root
sudo rm -rf /var/www/html
sudo ln -s /mnt/efs /var/www/html

# Create index.html and download image
cat <<EOF > /mnt/efs/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<title>Froggy for life...</title>
</head>
<body style="background-color:white;">
  <h1 style="color:green;">Welcome to My Web Server...Humans!</h1>
<img src="frog-png.png" alt="Frog Photo">
</body>
</html>
EOF

curl -o /mnt/efs/frog-png.png https://i.postimg.cc/hjCvPX9T/frog-png.png

# Verify files exist
if [ ! -f /mnt/efs/index.html ] || [ ! -f /mnt/efs/frog-png.png ]; then
    echo "Failed to create required files"
    exit 1
fi

# Install and configure CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration file
sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CustomMetrics",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}"
    }
  }
}
EOF

# Start CloudWatch agent with the new configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# Ensure CloudWatch agent starts on boot
sudo systemctl enable amazon-cloudwatch-agent

echo "CloudWatch agent configured and started"
echo "User data script execution completed"
