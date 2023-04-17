#!/bin/bash
#Installing NGINX
sudo apt update
sudo apt install -y nginx
sudo ufw allow 'Nginx HTTP'
sudo chmod -R 755 /var/www/html/index.nginx-debian.html
sudo rm /var/www/html/index.nginx-debian.html
echo '<html><head><title>LUSTINs Li-nux Server <3 </title></head><body style=\"background-color:#58D68D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\"> <h1>Hi BABY</h1> <p> Check out my webservers built via IaC on Microsoft Azure through Terraform</p> <p>Love you L &#10084;</p><h2>Love from Justin</h2></span></span></p></body></html>' | sudo tee /var/www/html/index.nginx-debian.html
