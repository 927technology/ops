#author: chris murray
#version: 0.1.9 (test 2)
#date 20241115

FROM oraclelinux:9
#FROM almalinux:9
LABEL maintainer="cmurray@927.technology"

#update os
RUN yum update -y

# pre-add files
COPY etc/yum.repos.d/naemon.repo /etc/yum.repos.d/
COPY ol/libmemcached-awesome-1.1.0-12.el9.x86_64.rpm /root/
COPY usr/local/bin/entrypoint.sh /usr/local/bin/
COPY usr/local/bin/gearmand.sh /usr/local/bin/
COPY usr/local/bin/naemon.sh /usr/local/bin/

# run installers
RUN /usr/local/bin/gearmand.sh
RUN /usr/local/bin/naemon.sh

# post-add files
COPY etc/naemon/conf.d/commands/test.cfg /etc/naemon/conf.d/commands/
COPY etc/naemon/conf.d/commands/test2.cfg /etc/naemon/conf.d/commands/
COPY etc/naemon/conf.d/servers/test.cfg /etc/naemon/conf.d/servers/
COPY etc/naemon/conf.d/servers/test2.cfg /etc/naemon/conf.d/servers/
COPY usr/lib64/nagios/plugins/test.sh /usr/lib64/nagios/plugins/
RUN chmod +x /usr/lib64/naemon/plugins/test.sh
RUN chmod +x /usr/lib64/naemon/plugins/test2.sh

# post install configurations
COPY etc/naemon/naemon.cfg /etc/naemon/naemon.cfg

EXPOSE 80/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]