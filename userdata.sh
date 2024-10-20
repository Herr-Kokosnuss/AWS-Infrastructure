#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Update the system
yum update -y
echo "System updated"

# Install Apache
yum install -y httpd
echo "Apache installed"

# Start Apache service
systemctl start httpd
systemctl enable httpd
echo "Apache started and enabled"

# Create a simple index.html file
echo '<!DOCTYPE html>' > /var/www/html/index.html
echo '<html lang="en">' >> /var/www/html/index.html

echo '<head>' >> /var/www/html/index.html
echo '<title>Froggy for life...</title>' >> /var/www/html/index.html
echo '</head>' >> /var/www/html/index.html

echo '<body style="background-color:white;">' >> /var/www/html/index.html
echo '  <h1 style="color:green;">Welcome to My Web Server...Humans!</h1>' >> /var/www/html/index.html
echo '<img src="frog-png.png" alt="Frog Photo">' >> /var/www/html/index.html

echo '</body>' >> /var/www/html/index.html
echo '</html>' >> /var/www/html/index.html

echo "Index.html file created"

echo "User data script execution completed"
curl -o /var/www/html/frog-png.png https://i.postimg.cc/hjCvPX9T/frog-png.png