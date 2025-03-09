#!/bin/bash

# main
# prerequisites
yum install -y yum-utils oracle-epel-release-el9
yum install -y naemon nagios-plugins-ping mod_ssl net-snmp net-snmp-utils

rm -f  /etc/httpd/conf.d/welcome.conf

rm -rf /etc/naemon/*.cfg
rm -rf /etc/naemon/conf.d/*.cfg
rm -rf /etc/naemon/conf.d/{commands,instances,network,servers,templates}

mkdir -p /etc/927
chown -R naemon:naemon /etc/927
chmod -R 770 /etc/927

chown -R naemon:naemon /usr/local/etc/ops
chmod -R 440 /usr/local/etc/ops

mkdir -p /usr/lib64/nagios/plugins
chown -R naemon:naemon /usr/lib64/nagios/plugins
chmod 755 /usr/lib64/nagios/plugins
