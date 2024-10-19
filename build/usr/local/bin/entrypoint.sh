#!/bin/bash

case ${ROLE} in
  ms )
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/bin/naemon --verify-config /etc/naemon/naemon.cfg"                     && \
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/sbin/gearmand -d --log-file none --syslog $OPTIONS"                    && \
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/bin/mod_gearman_worker -d --config=/etc/mod_gearman/worker.conf"       && \
    /usr/sbin/httpd $OPTIONS -DBACKGROUND                                                                                         && \
    /bin/su naemon --login --shell=/bin/sh "--command=/usr/bin/naemon /etc/naemon/naemon.cfg"
  ;;
esac