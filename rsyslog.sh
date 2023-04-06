#!/bin/bash
if [ -z '.env' ]; then 
    echo 'No .env detected, creating one now'
    perl ./make-env.pl
fi
[ "$EUID" -ne 0 ] && echo 'You need to be root to run this.' && exit 1

$packagesNeeded='rsyslog-mysql'
if [ -x "$(command -v apk)" ];       then sudo apk add --no-cache $packagesNeeded
elif [ -x "$(command -v apt-get)" ]; then sudo apt-get -y install $packagesNeeded
elif [ -x "$(command -v dnf)" ];     then sudo dnf install $packagesNeeded
elif [ -x "$(command -v zypper)" ];  then sudo zypper install 'rsyslog-module-mysql' # :(
else echo 'Could not identify package manager to install "rsyslog-mysql" please install it yourself and retry.'

export $(cat .env | xargs)
cp rsyslog.d/remote.conf /etc/rsyslog.d/remote.conf
sed -e "s/{h}/${MYSQL_HOST}/" -e "s/{p}/${MYSQL_PASS}/" rsyslog.d/mysql.conf > /etc/rsyslog.d/mysql.conf

chown root:root /etc/rsyslog.d/remote.conf
chown root:root /etc/rsyslog.d/mysql.conf

chmod 700 /etc/rsyslog.d/remote.conf
chmod 700 /etc/rsyslog.d/mysql.conf
if [ -x "$(command -v systemctl) "]; then
    systemctl restart rsyslog.service
    echo "Successfully setup rsyslog for use with Clark."
else
    echo "Could not figure out your init system (we only support SystemD), please restart rsyslog to complete the setup."
fi