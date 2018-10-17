#!/bin/bash

echo "Setup of proxy pass ..." >> /var/log/bootstrap.log 2>&1

apt-get update >> /var/log/bootstrap.log 2>&1
apt-get -y install squid3 >> /var/log/bootstrap.log 2>&1

cp /etc/squid/squid.conf /etc/squid/squid.conf.old >> /var/log/bootstrap.log 2>&1
# Squid config file
cat << EOF > /etc/squid/squid.conf
acl local_network src ${LOCAL_NETWORK_CIDR}
acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 21          # ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localhost
http_access allow local_network
http_access deny all
http_port 3128 vhost
coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern (Release|Packages(.gz)*)$      0       20%     2880
refresh_pattern .               0       20%     4320

EOF

service squid restart >> /var/log/bootstrap.log 2>&1

echo "End setup of proxy pass ..." >> /var/log/bootstrap.log 2>&1