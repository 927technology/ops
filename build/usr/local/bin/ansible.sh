#!/bin/bash

# install
yum install -y ansible-core

# plugins
ansible-galaxy collection install ansible.posix