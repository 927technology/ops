#!/bin/bash

# main
# prerequisites
yum install -y yum-utils oracle-epel-release-el9
yum install -y naemon nagios-plugins-ping
rpm -e mod_gearman
rpm -i /root/build/ol/naemon-livestatus-1.4.3.rhel9.x86_64.rpm

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
