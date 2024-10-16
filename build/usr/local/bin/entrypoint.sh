#!/bin/bash

case ${ROLE} in
  ms )
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/bin/naemon --verify-config /etc/naemon/naemon.cfg" && \
    /usr/sbin/gearmand -d --log-file none --syslog $OPTIONS                                                   && \
    /usr/sbin/httpd $OPTIONS -DBACKGROUND                                                                     && \
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/bin/naemon /etc/naemon/naemon.cfg"
  ;;
esac