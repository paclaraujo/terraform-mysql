#!/usr/bin/env bash

DBPASSWORD=root

sudo apt-get update && \

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWORD" && \
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWORD" && \

sudo apt-get install -y mysql-server-5.7