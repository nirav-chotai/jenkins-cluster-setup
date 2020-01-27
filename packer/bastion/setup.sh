#!/usr/bin/env bash

echo "Install Telegraf"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start

echo "Setup SSH key"
mv /tmp/id_rsa /home/ec2-user/.ssh/id_rsa