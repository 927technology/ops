#!/bin/bash

# main
## prerequisites
yum install -y yum-utils oracle-epel-release-el9

# disable naemon repo
yum-config-manager --disable home_naemon

# install gearmand
rpm -i /root/libmemcached-awesome-1.1.0-12.el9.x86_64.rpm
yum install -y gearmand 

# enable naemon repo
yum-config-manager --enable home_naemon

# install mod_gearman
yum install -y mod_gearman