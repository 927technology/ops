#!/bin/bash

gearman_packages=mod-gearman-module,mod-gearman-tools,mod-gearman-worker
log_folder=/var/log

#banner
echo -e "\n  Installing ModGearman"
echo -e "=========================================================================================="
apt update 1> ${log_folder}/gearman.log 2> ${log_folder}/gearman_err.log


apt install -y gnupg1

curl -s "https://labs.consol.de/repo/stable/RPM-GPG-KEY" | apt-key add -
echo "deb http://labs.consol.de/repo/stable/ubuntu focal main" > /etc/apt/sources.list.d/labs-consol-stable.list
apt update


#get gearman deb packages
for gearman_package in `echo ${gearman_packages} | sed 's/\,/\ /g'`; do
	#install gearman deb package
	echo -e "  installing ${gearman_package}"
       	apt install -y ${gearman_package} 1> ${log_folder}/gearman.log 2> ${log_folder}/gearman_err.log
done

echo -e "\n"
