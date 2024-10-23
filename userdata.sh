#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Install necessary packages
sudo yum update -y
sudo yum install -y amazon-efs-utils httpd

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Create mount directory
sudo mkdir -p /mnt/efs

# Mount EFS with specific options
sudo mount -t efs -o tls,iam ${efs_id}:/ /mnt/efs

# Add mount to fstab for persistence across reboots
echo "${efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Mount the EFS file system
sudo mount -a

# Set permissions
sudo chmod 777 /mnt/efs

# Create a simple index.html file on EFS
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
echo "Index.html file created on EFS"

# Download the frog image to EFS
curl -o /mnt/efs/frog-png.png https://i.postimg.cc/hjCvPX9T/frog-png.png

# Create symbolic links from the Apache document root to the EFS mount
sudo ln -sf /mnt/efs/index.html /var/www/html/index.html
sudo ln -sf /mnt/efs/frog-png.png /var/www/html/frog-png.png

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