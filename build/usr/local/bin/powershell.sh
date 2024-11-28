#!/bin/bash

curl -s https://packages.microsoft.com/config/rhel/9/prod.repo > /etc/yum.repos.d/microsoft.repo
dnf update
dnf install --assumeyes powershell

pwsh -Command Install-Module -Name VMware.PowerCLI -Force

echo -e "yes\n" | pwsh -Command Set-PowerCLIConfiguration -InvalidCertificateAction Ignore