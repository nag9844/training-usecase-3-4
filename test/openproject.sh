#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
 
docker run -d -p 8080:8080 --name openproject openproject/community:latest