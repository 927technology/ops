#author: chris murray
#version: 0.1.36
#date 20240309

FROM oraclelinux:9
LABEL maintainer="cmurray@927.technology"

# environmental variables 
ENV ANSIBLE_JSON_INDENT=0
ENV ANSIBLE_CUSTOM_STATS=false
ENV 927_BUILD=0.1.36
ENV 927_NAME=ops

# add epel
RUN yum install -y oracle-epel-release-el9

# update os
RUN yum check-update; yum update -y

# pre-add files
COPY etc/environment /etc/
COPY etc/yum.repos.d/naemon.repo /etc/yum.repos.d/
COPY ol/libmemcached-awesome-1.1.0-12.el9.x86_64.rpm /root/
COPY ol/osquery-5.13.1-1.linux.x86_64.rpm /root/
COPY usr/local/opt /usr/local/opt
COPY usr/local/bin /usr/local/bin
COPY usr/local/etc /usr/local/etc
COPY usr/local/lib /usr/local/lib

# installers
RUN /usr/local/bin/ansible.sh
RUN /usr/local/bin/gearmand.sh
RUN /usr/local/bin/naemon.sh
RUN /usr/local/bin/powershell.sh
RUN /usr/local/bin/terraform.sh

# post-add files
COPY etc/naemon/ /etc/naemon
COPY etc/httpd/conf.d/927.conf /etc/httpd/conf.d
COPY etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d
COPY etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
COPY usr/lib64/nagios/plugins/ /usr/lib64/nagios/plugins
COPY usr/share/thruk/support/thruk_templates.cfg /usr/share/thruk/support/
COPY etc/ansible/ /etc/ansible
# COPY ssh/ops-ms.pem /root/ssh/
# COPY oci/config /root/oci/

# post installer
RUN  /usr/local/bin/post.sh

EXPOSE 80/tcp 
EXPOSE 443/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
