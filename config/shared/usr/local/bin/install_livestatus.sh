#!/bin/bash

version_livestatus_package=1.2.6

url_livestatus_package=http://mathias-kettner.de/download/mk-livestatus-${version_livestatus_package}.tar.gz

source_livestatus_package=`echo ${url_livestatus_package} | awk -F"/" '{print $NF}'`
livestatus_package=`echo mk-livestatus-${version_livestatus_package}.tar.gz | sed 's/.gz//g' | sed 's/.tar//g'`
sources_folder=/src
log_folder=/var/log

export DEBIAN_FRONTEND=noninteractive

#banner
echo -e "\n  Installing Livestatus"
echo -e "=========================================================================================="


#install dependancies
echo -e "  installing dependancies"
apt update 1> ${log_folder}/gearman.log 2> ${log_folder}/gearman_err.log
apt install -y debconf-set-selections 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
apt install -y autoconf gcc libc6 make wget libgd-dev jq libmcrypt-dev libssl-dev gawk dc build-essential 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log


#get livestatus source packages
if [ ! -f ${sources_folder}/${livestatus_package} ]; then
       	echo -e "  download package - `echo ${livestatus_package} | awk -F"-" '{print $1}'` ${version_livestatus_package}"
       	wget ${url_livestatus_package}/${livestatus_package} -P ${sources_folder}/ 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log
fi


#unpack source - nagios
####################################################################################################
echo -e "  unpacking livestatus ${version_livestatus_package}"
tar xf ${sources_folder}/${source_livestatus_package} -C ${temp_folder}/
echo -e  "  entering install folder ${temp_folder}/${version_livestatus_package}"
cd ${temp_folder}/${livestatus_package}


./configure --with-nagios4 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log
make install 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log

#add broker module if missing
if [ `grep -c livestatus.o /etc/nagios/nagios.cfg` -eq 0 ]; then
	echo -e "  adding broker module"
	echo broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/rw/live >> /etc/nagios/nagios.cfg
fi

if [ ! -d /usr/lib64/nagios/rw ]; then
	echo -e "  creating livestatus socket"
	mkdir -p /usr/local/nagios/rw 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log
fi

echo -e "  setting permissions on livestatus socket"
chown root:nagios /usr/local/nagios/rw 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log
chmod 770 /usr/local/nagios/rw 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log
chmod g+s /usr/local/nagios/rw 1> ${log_folder}/livestatus.log 2> ${log_folder}/livestatus_err.log

echo -e "\n"
