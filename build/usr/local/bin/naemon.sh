#!/bin/bash

# main
# prerequisites
yum install -y yum-utils oracle-epel-release-el9
yum install -y naemon

mkdir -p /etc/naemon/conf.d/{instances,network,terraform}
mkdir -p /usr/lib64/nagios/plugins
chown -R naemon:naemon /usr/lib64/nagios/plugins
chmod 755 /usr/lib64/nagios/plugins
