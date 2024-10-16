#nagios
yum install -y gcc glibc glibc-common wget unzip httpd make php gd gd-devel perl postfix
tar xf /src/nagios-4.4.6.tar.gz -C /tmp/
cd /tmp/nagios-4.4.6
./configure --prefix= --sysconfdir=/etc/nagios
make all

make install-groups-users
usermod -a -G nagios apache

make install

make install-daemoninit
systemctl enable httpd.service

make install-commandmode

make install-config

make install-webconf


htpasswd -bc /etc/nagios/htpasswd.users nagiosadmin nagiosadmin



#plugins
yum install -y epel-release
yum check-update
yum install -y wget jq net-snmp 

tar xf /src/nagios-plugins-2.3.3.tar.gz -C /tmp/
cd /tmp/nagios-plugins-release-2.3.3/
./configure --libexecdir=/usr/lib64/yunagios/plugins
make
make install

#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#rpm -ihv epel-release-latest-7.noarch.rpm
#subscription-manager repos --enable=rhel-7-server-optional-rpms
#yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils
#yum install -y perl-Net-SNMP

#gearman
rpm -Uvh "https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm"
yum check-update
yum install -y mod_gearman gearmand gearmand-server

#pnp4nagios
yum install -y rrdtool php-gd
tar -xf /src/pnp4nagios-0.6.26.tar.gz -C /tmp/
cd /tmp/pnp4nagios-0.6.26
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make all; make fullinstall



#livestatus
yum install -y make gcc-c++
tar xf /src/mk-livestatus-1.2.6.tar.gz -C /tmp
cd /tmp/mk-livestatus-1.2.6
./configure –with-nagios4
make
make install
echo broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/lib64/nagios/rw/live >> /etc/nagios/nagios.cfg
mkdir -p /usr/lib64/nagios/rw
chown root:nagios /usr/lib64/nagios/rw
chmod 770 /usr/lib64/nagios/rw
chmod g+s /usr/lib64/nagios/rw

#thruk
yum install -y /src/libthruk-2.18-1.rhel7.x86_64.rpm 
yum install -y /src/thruk-base-2.18-1.rhel7.x86_64.rpm
yum install -y /src/thruk-plugin-reporting-2.18-1.rhel7.x86_64.rpm
mkyum install -y /src/thruk-2.18-1.rhel7.x86_64.rpm

