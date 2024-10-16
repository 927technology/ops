#!/bin/bash

##this install is for ubuntu 20.04


url_nagios_package=https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
url_plugins_nagios_package=https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz

source_nagios_package=`echo ${url_nagios_package} | awk -F"/" '{print $NF}'`
source_plugins_nagios_package=`echo ${url_plugins_nagios_package} | awk -F"/" '{print $NF}'`
version_nagios_package=`echo ${source_nagios_package} | sed 's/.gz//g' | sed 's/.tar//g'`
version_plugins_nagios_package=`echo ${source_plugins_nagios_package} | sed 's/.gz//g' | sed 's/.tar//g'`
sources_folder=/src
temp_folder=/tmp
log_folder=/var/log

export DEBIAN_FRONTEND=noninteractive


#banner
echo -e "\n  Install Nagios"
echo -e "=========================================================================================="

#update apt cache
echo -e "  updating apt cache"
apt update  1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
echo -e "  install debconf-set-selections"
apt install -y debconf-set-selections 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install dependancies
echo -e "  installing dependancies"
apt install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.4 libgd-dev jq wget libmcrypt-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext  1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#create sources folder if missing
if [ ! -d ${sources_folder} ]; then
	echo -e "  make source directory"
	mkdir -p ${sources_folder}
fi

#download nagios package if not present
if [ ! -f ${sources_folder}/${source_nagios_package} ]; then
	echo -e "  download source file - nagios `echo ${version_nagios_package} | awk -F"-" '{print $2}'`"
	wget -q ${url_nagios_package} -P ${sources_folder}/
fi
#download nagios plugins package if not present
if [ ! -f ${sources_folder}/${source_plugins_nagios_package} ]; then
	echo -e "  download source file - nagios_plugins `echo ${version_plugins_nagios_package} | awk -F"-" '{print $2}'`"
	wget --no-check-certificate -q ${url_plugins_nagios_package} -P ${sources_folder}/
fi

#unpack source - nagios
####################################################################################################
echo -e "  unpacking nagios `echo ${version_nagios_package} | awk -F"-" '{print $2}'`"
tar xf ${sources_folder}/${source_nagios_package} -C ${temp_folder}/
echo -e  "  entering install folder ${temp_folder}/${version_nagios_package}"
cd ${temp_folder}/${version_nagios_package}

#install source - nagios
echo -e "  installing nagios ${version_nagios_package}"
./configure --prefix= --sysconfdir=/etc/nagios --with-httpd-conf=/etc/apache2/sites-enabled  1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
make all 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#create user groups
echo -e "  create user groups"
make install-groups-users 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
usermod -aG nagios www-data
make all 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install binaries
echo -e "  install binaries"
make install 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install daemon **is this necessary?
echo -e "  install daemon"
make install-demoninit 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install command mode
echo -e "  install commandmode"
make install-commandmode 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install config files
echo -e "  install config"
make install-config 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#install apache config files
echo -e "  install apache config files"
make install-webconf 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
a2enmod rewrite 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
a2enmod cgi 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log

#configure firewall **not necessary in docker
#ufw allow Apache
#ufw reload

#create htpasswd file
read -s -p "  NagiosAdmin Password: " nagios_password
echo -e "\n"

htpasswd -bc /etc/nagios/htpasswd.users nagiosadmin ${nagios_password} 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
chown nagios:www-data /etc/nagios/htpasswd.users
chmod 440 /etc/nagios/htpasswd.users
#--------------------------------------------------------------------------------------------------
#end install source nagios


#banner
echo -e "  Install Nagios - Plugins"
echo -e "------------------------------------------------------------------------------------------"

#unpack source - nagios_plugins
####################################################################################################
echo -e "  unpacking nagios_plugins `echo ${version_plugins_nagios_package} | awk -F"-" '{print $2}'`"
tar xf ${sources_folder}/${source_plugins_nagios_package} -C ${temp_folder}/
echo -e "  entering install folder ${temp_folder}/${version_plugins_nagios_package}"

#install source - nagios_plugins
echo -e "  installing nagios_plugins ${version_plugins_nagios_package}"
cd ${temp_folder}/${version_plugins_nagios_package}/
./configure --with-nagios-user=nagios --with-nagios-group=nagios 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
make 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
make install 1> ${log_folder}/nagios.log 2> ${log_folder}/nagios_err.log
echo -e "\n"
#--------------------------------------------------------------------------------------------------

