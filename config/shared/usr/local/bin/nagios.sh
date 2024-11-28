#!/bin/bash

yum check-update
yum install -y epel-release


#nagios
yum check-update
yum install -y nagios nagios-plugins-all jq snmp-utils check-mk-livestatus pnp4nagios


if [ `grep -c /usr/lib64/check_mk/livestatus/livestatus.o /etc/nagios/nagios.cfg` -eq 0 ]; then
    echo broker_module=/usr/lib64/check_mk/livestatus/livestatus.o /usr/lib64/nagios/rw/live >> /etc/nagios/nagios.cfg
fi

mkdir -p /usr/lib64/nagios/rw
chown root:nagios /usr/lib64/nagios/rw
chmod 770 /usr/lib64/nagios/rw
chmod g+s /usr/lib64/nagios/rw


#gearman
rpm -Uvh "https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm"
yum check-update
yum install -y mod_gearman gearmand gearmand-server

if [ `grep -c /usr/lib64/mod_gearman/mod_gearman_nagios4.o /etc/nagios/nagios.cfg` -eq 0 ]; then
    echo broker_module=/usr/lib64/mod_gearman/mod_gearman_nagios4.o config=/etc/mod_gearman/module.conf >> /etc/nagios
fi


#thruk
yum install -y /src/libthruk-2.18-1.rhel7.x86_64.rpm 
yum install -y /src/thruk-base-2.18-1.rhel7.x86_64.rpm
yum install -y /src/thruk-plugin-reporting-2.18-1.rhel7.x86_64.rpm
yum install -y /src/thruk-2.18-1.rhel7.x86_64.rpm
