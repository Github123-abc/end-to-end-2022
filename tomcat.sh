#!/bin/bash
# yum -y update
# amazon-linux-extras install java-openjdk11 -y
# java -version
# cd /opt
# wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.69/bin/apache-tomcat-9.0.69.tar.gz
# tar -xf apache-tomcat-9.0.69.tar.gz
# cd apache-tomcat-9.0.69/
# cd bin/
# sh startup.sh
# cd /opt
# wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
#  tar -zvxf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
#  cd node_exporter-1.4.0-rc.0.linux-amd64/
# ./node_exporter
# nohup ./node_exporter &

# sudo su -
# yum update -y
# amazon-linux-extras install java-openjdk11 -y
# cd /opt/
# wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.27/bin/apache-tomcat-10.0.27.tar.gz
# tar -xvzf apache-tomcat-10.0.27.tar.gz
# mv apache-tomcat-10.0.27 tomcat
# rm -rf apache-tomcat-10.0.27.tar.gz
# cd tomcat/
# cd bin/
# sh startup.sh
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



