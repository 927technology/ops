# ops

Monitoring & Compliance Solution

To expand the limitations of monitoring and accreditaion compliance, i have found it increasingly difficult to reasonably determine if systems are within requirements.  Utilizing the livestatus pipe i can now distribute access to Nagios' status to 1M intervals and reduce vunerable configuration files to compormise/alteration to that window without adversely impacting CPU loads.  

i have created a polling engine to parse hosts from Nagios and consume their statuses utilzing various collection mechanisms such as SNMP, WMIC, API calls and NRPE.  This data is consumed and stored as json for easy consumption by Nagios.

Current Polling Agents
GNS3 - Native Json via API
Junos - Native Json via API
Linux - Native Json via osquery and NRPE
Cisco - Translated JSON from SNMP


Usage:
install docker-compose
https://docs.docker.com/compose/install/

Clone repisitory 

Extract 927_ops.tar.gz
tar xzf 927_ops.tar.gz

Start Container
cd ops
docker-compose up
