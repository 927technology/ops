#!/bin/bash

# main
# prerequisites
yum install -y yum-utils oracle-epel-release-el9
yum install -y naemon

mkdir -p /etc/naemon/conf.d/{instances,network,terraform}
