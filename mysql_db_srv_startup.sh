#!/bin/bash

#system repository updating
echo 'system update'
apt update
apt upgrade -y

#adding mysql v. 5.7 to apt installation repository
echo 'adding repos to source list'
echo 'deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-apt-config' >>/etc/apt/sources.list.d/mysql.list
echo 'deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7' >>/etc/apt/sources.list.d/mysql.list
echo 'deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-tools' >>/etc/apt/sources.list.d/mysql.list
echo 'deb-src http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7' >>/etc/apt/sources.list.d/mysql.list

#adding install-key for legacy version
echo 'adding key'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8C718D3B5072E1F5

#updating system with new source repository
apt update
apt upgrade -y

#installation of mysql client
echo 'installing mysql-client'
apt install -f -y mysql-client

#installation of mysql server
echo 'installing mysql-server'
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
echo 'mysql installed'

#creating database
echo 'creating DATABASE'
echo 'CREATE DATABASE eschool;' >db_creating.tmp
mysql <db_creating.tmp

#creating user
echo 'creating USER'
echo 'CREATE USER '\'${DATASOURCE_USERNAME}\''@'\''%'\'' IDENTIFIED BY '\'${DATASOURCE_PASSWORD}\'';' >user_creating.tmp
mysql <user_creating.tmp

#granting privileges to user
echo 'granting PRIVILEGES'
echo 'GRANT ALL PRIVILEGES ON *.* TO '\'${DATASOURCE_USERNAME}\''@'\''%'\'';' >db_prev.tmp
mysql <db_prev.tmp

#removing temporary files
rm db_prev.tmp
rm db_creating.tmp
rm user_creating.tmp

echo 'DATABASE configuration - done'

#open mysql server for remote connection
echo 'mysqld.cnf configuration'
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'done'

#restarting mysql service with new parameters
systemctl enable mysql
echo 'restart mysql'
systemctl restart mysql
echo 'done'
