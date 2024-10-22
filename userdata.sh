#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Update the system
yum update -y
echo "System updated"

# Install Apache and Amazon EFS utilities
yum install -y httpd amazon-efs-utils
echo "Apache and EFS utils installed"

# Start Apache service
systemctl start httpd
systemctl enable httpd
echo "Apache started and enabled"

# Mount EFS
mkdir -p /mnt/efs
mount -t efs -o tls ${efs_id}:/ /mnt/efs
echo "${efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

echo "EFS mounted"

# Create a simple index.html file on EFS
echo '<!DOCTYPE html>' > /mnt/efs/index.html
echo '<html lang="en">' >> /mnt/efs/index.html
echo '<head>' >> /mnt/efs/index.html
echo '<title>Froggy for life...</title>' >> /mnt/efs/index.html
echo '</head>' >> /mnt/efs/index.html
echo '<body style="background-color:white;">' >> /mnt/efs/index.html
echo '  <h1 style="color:green;">Welcome to My Web Server...Humans!</h1>' >> /mnt/efs/index.html
echo '<img src="frog-png.png" alt="Frog Photo">' >> /mnt/efs/index.html
echo '</body>' >> /mnt/efs/index.html
echo '</html>' >> /mnt/efs/index.html
echo "Index.html file created on EFS"

# Download the frog image to EFS
curl -o /mnt/efs/frog-png.png https://i.postimg.cc/hjCvPX9T/frog-png.png

# Create symbolic links from the Apache document root to the EFS mount
ln -s /mnt/efs/index.html /var/www/html/index.html
ln -s /mnt/efs/frog-png.png /var/www/html/frog-png.png

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration file
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60
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
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

echo "CloudWatch agent configured and started"

echo "User data script execution completed"
