#!/bin/sh
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum remove java-1.7.0-openjdk -y
yum install java-1.8.0-openjdk -y
yum install jenkins -y
service jenkins start
yum-config-manager --enable epel
yum install ansible
