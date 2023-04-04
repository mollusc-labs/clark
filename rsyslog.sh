#!/bin/bash
if [ -z '.env' ]; then 
    echo 'No .env detected, creating one now'
    perl ./make-env.pl
fi
[ "$EUID" -ne 0 ] && echo 'You need to be root to run this.' && exit 1
apt-get install -y rsyslog-mysql
export $(cat .env | xargs)
cp rsyslog.d/remote.conf /etc/rsyslog.d/remote.conf
sed -e "s/{h}/${MYSQL_HOST}/" -e "s/{p}/${MYSQL_PASS}/" rsyslog.d/mysql.conf > /etc/rsyslog.d/mysql.conf

chown root:root /etc/rsyslog.d/remote.conf
chown root:root /etc/rsyslog.d/mysql.conf

chmod 700 /etc/rsyslog.d/remote.conf
chmod 700 /etc/rsyslog.d/mysql.conf

systemctl restart rsyslog.service