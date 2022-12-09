#!/bin/bash
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade -y
amazon-linux-extras install java-openjdk11 -y
yum install jenkins -y
systemctl start jenkins
systemctl enable jenkins
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
 tar -zvxf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
 cd node_exporter-1.4.0-rc.0.linux-amd64/
# ./node_exporter
nohup ./node_exporter &