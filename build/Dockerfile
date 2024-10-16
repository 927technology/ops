#author: chris murray
#version: 0.1.7
#date 20241115

FROM oraclelinux:9
#FROM almalinux:9
LABEL maintainer="cmurray@927.technology"

#update os
RUN yum update -y

# add files
COPY etc/yum.repos.d/naemon.repo /etc/yum.repos.d/
COPY ol/libmemcached-awesome-1.1.0-12.el9.x86_64.rpm /root/
COPY usr/local/bin/entrypoint.sh /usr/local/bin/
COPY usr/local/bin/gearmand.sh /usr/local/bin/
COPY usr/local/bin/naemon.sh /usr/local/bin/

# run installers
RUN /usr/local/bin/gearmand.sh
RUN /usr/local/bin/naemon.sh

# post install configurations
COPY etc/naemon/naemon.cfg /etc/naemon/naemon.cfg

EXPOSE 80/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]