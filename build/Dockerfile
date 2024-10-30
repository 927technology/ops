#author: chris murray
#version: 0.1.17
#date 20241120

FROM oraclelinux:9
LABEL maintainer="cmurray@927.technology"

#update os
RUN yum update -y

# pre-add files
COPY etc/environment /etc/
COPY etc/yum.repos.d/naemon.repo /etc/yum.repos.d/
COPY ol/libmemcached-awesome-1.1.0-12.el9.x86_64.rpm /root/
COPY ol/osquery-5.13.1-1.linux.x86_64.rpm /root/
COPY usr/local/bin /usr/local/bin
COPY usr/local/lib /usr/local/lib

# installers
RUN /usr/local/bin/gearmand.sh
RUN /usr/local/bin/naemon.sh

# post-add files
COPY etc/naemon/ /etc/naemon
COPY usr/lib64/nagios/plugins/ /usr/lib64/nagios/plugins
COPY usr/share/thruk/support/thruk_templates.cfg /usr/share/thruk/support/
# COPY ssh/ops-ms.pem /root/ssh/
# COPY oci/config /root/oci/

# post installer
RUN  /usr/local/bin/post.sh

EXPOSE 80/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]