#!/bin/sh
yum update -y
yum remove java-1.7.0-openjdk -y
yum install java-1.8.0-openjdk -y
yum install tomcat -y
service tomcat start
yum install docker -y
service docker start