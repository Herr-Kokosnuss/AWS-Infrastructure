##!/bin/bash
yum update -y
yum install -y httpd 
systemctl start httpd
systemctl enable httpd

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

curl -o /var/www/html/frog-png.png https://i.postimg.cc/hjCvPX9T/frog-png.png

