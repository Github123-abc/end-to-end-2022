#!/bin/bash
#installing Filebeat
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update
sudo apt-get install filebeat
sudo sed -i 's/  enabled: false/  enabled: true/g' /etc/filebeat/filebeat.yml
sudo systemctl start filebeat.service
sudo systemctl enable filebeat.service
#Tomcat installation
sudo apt install openjdk-11-jdk -y
sudo su -
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.27/bin/apache-tomcat-10.0.27.tar.gz
tar -zvxf apache-tomcat-10.0.27.tar.gz
cd apache-tomcat-10.0.27/bin/
./startup.sh
sudo sed -i 's%/var/log/\*.log%/opt/apache-tomcat-10.0.27/logs/\*log*%' /etc/filebeat/filebeat.yml
sudo sed -i 's%"localhost:9200"%"aws_instance.ek.public_ip:9200"%' /etc/filebeat/filebeat.yml