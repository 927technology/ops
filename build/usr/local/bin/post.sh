#!/bin/bash

# jq
yum install -y jq

# osquery
yum install -y /root/osquery-5.13.1-1.linux.x86_64.rpm

# set naemon permissions
chown -R naemon:naemon /etc/naemon
chmod -R 755 /etc/naemon

# add ssh priv keyfiles
mkdir -p /var/mod_gearman/.ssh
mv /root/ssh/* /var/mod_gearman/.ssh/
chmod 700 /var/mod_gearman/.ssh
chmod 600 /var/mod_gearman/.ssh/*
chown -R naemon:naemon /var/mod_gearman/.ssh

# install oci cli
/bin/su naemon --login --shell=/bin/sh "--command=/usr/local/bin/oci-cli.sh --accept-all-defaults"

# add oci configuration
mkdir -p /var/mod_gearman/.oci
mv /root/oci/config /var/mod_gearman/.oci/
chmod 700 /var/mod_gearman/.oci
chmod 600 /var/mod_gearman/.oci/*
chown -R naemon:naemon /var/mod_gearman/.oci


# allow to read libs
chmod -R 555 /usr/local/etc
