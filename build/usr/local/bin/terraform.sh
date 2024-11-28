#!/bin/bash

# install yum-utils
yum insall -y yum-utils

# add hashicorp repo
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# install terraform
yum -y install terraform