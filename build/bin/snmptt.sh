#!/bin/bash

yum install -y epel-release
yum check-update
yum install -y snmptt perl-Sys-Syslog
