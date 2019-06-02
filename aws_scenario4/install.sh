#!/bin/sh
yum install -y httpd
service httpd start
echo "<html><h1>Toast ^^</h2></html>" > /var/www/html/index.html