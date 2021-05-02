# ops
#Monitoring Solution

#to expand the limitations of monitoring and accreditaion compliance, i have found it increasingly difficult to reasonably determine if systems are within requirements.  utilizing the livestatus pipe i can now distribute access to nagios' status to 1m intervals and reduce vunerable configuration files to compormise/alteration to that window.  i have created a polling engine to parse hosts from nagios and consume their statuses utilzing various collection mechanisms such as snmp, wmic, api calls, and nrpe.  this data is consumed and stored as json for easy consumption by nagios.

#current devices that have polling agents

#GNS3 - Native Json via API
#Junos - Native Json via API
#Linux - Native Json via osquery and NRPE
#Cisco - Translated JSON from SNMP


#install docker-compose
https://docs.docker.com/compose/install/

#download docker-compose.yml and 927_ops.tar.gz into a folder.  

#extract 927_ops.tar.gz

tar xzf 927_ops.tar.gz

#start container

cd ops

docker-compose up
