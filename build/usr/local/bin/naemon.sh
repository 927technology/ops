#!/bin/bash

# main
# prerequisites
yum install -y yum-utils oracle-epel-release-el9
yum install -y naemon nagios-plugins-ping net-snmp

rm -rf /etc/naemon/*.cfg
rm -rf /etc/naemon/conf.d/*.cfg
rm -rf /etc/naemon/conf.d/{commands,instances,network,servers,templates}

mkdir -p /usr/lib64/nagios/plugins
chown -R naemon:naemon /usr/lib64/nagios/plugins
chmod 755 /usr/lib64/nagios/plugins