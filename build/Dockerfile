#author: chris murray
#version: 1.1
#date 20200423
#dockerfile nagios-management_server

FROM centos:7
LABEL maintainer="cmurray@927.technology"

#update os
#RUN yum check-update
#RUN yum update -y

#copy install nagios
RUN mkdir -p /src
COPY ./src/libthruk-2.18-1.rhel7.x86_64.rpm /src/
COPY ./src/thruk-base-2.18-1.rhel7.x86_64.rpm /src/
COPY ./src/thruk-plugin-reporting-2.18-1.rhel7.x86_64.rpm /src/
COPY ./src/thruk-2.18-1.rhel7.x86_64.rpm /src/

COPY ./bin/nagios.sh /usr/local/bin/
RUN /usr/local/bin/nagios.sh

COPY ./bin/snmptt.sh /usr/local/bin/
RUN /usr/local/bin/snmptt.sh

COPY ./bin/nmap.sh /usr/local/bin/
RUN /usr/local/bin/nmap.sh

#EXPOSE 80/tcp

#entrypoint
COPY ./bin/entrypoint.sh /usr/local/sbin/
ENTRYPOINT /usr/local/sbin/entrypoint.sh
