#!/bin/bash

# bools
true=1
false=0

# commands
cmd_httpd=/usr/sbin/httpd
cmd_ops=/usr/local/bin/ops.sh
cmd_sleep=/usr/bin/sleep
cmd_su=/bin/su

# variables
_sleep=60


if [[ "${MANAGEMENT}" == "true" ]]; then
  ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_ops}"

  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/sbin/gearmand -d --log-file none --syslog $OPTIONS"                    && \
  ${cmd_httpd} $OPTIONS -DBACKGROUND                                                                                              && \
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/bin/naemon --daemon /etc/naemon/naemon.cfg"  
fi

if [[ "${WORKER}" == "true" ]]; then
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/bin/mod_gearman_worker -d --config=/etc/mod_gearman/worker.conf"
fi


while [[ ${true} ]]; do

  ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_ops} "
  ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_sleep} ${_sleep}"

done