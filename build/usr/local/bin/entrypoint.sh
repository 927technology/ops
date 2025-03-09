#!/bin/bash

# bools
true=1
false=0

# commands
cmd_echo=/bin/echo
cmd_httpd=/usr/sbin/httpd
cmd_ops_ms=/usr/local/bin/ms.sh
cmd_sleep=/usr/bin/sleep
cmd_su=/bin/su

# variables
_sleep=60


if [[ "${MANAGEMENT}" == "true" ]]; then
  ${cmd_echo} Starting Gearmand
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/sbin/gearmand -d --log-file none --syslog $OPTIONS"
  
  ${cmd_echo} Starting Apache
  ${cmd_httpd} -DBACKGROUND

fi

if [[ "${WORKER}" == "true" ]]; then
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/bin/mod_gearman_worker -d --config=/etc/mod_gearman/worker.conf"
fi


while [[ ${MANAGEMENT} == "true" ]]; do

  if [[ ! -f /var/mod_gearman/secrets/ops.927.technology.cert ]] && [[ ! -f /var/mod_gearman/secrets/ops.927.technology.key ]]; then
    openssl req                                                               \
      -days   3650                                                            \
      -keyout /var/mod_gearman/secrets/ops.927.technology.key                 \
      -newkey rsa:2048                                                        \
      -nodes                                                                  \
      -subj   "/C=US/ST=MS/L=Gulfport/O=927 Technology/CN=ops.927.technology" \
      -out    /var/mod_gearman/secrets/ops.927.technology.cert                \
      -x509
  fi


  ${cmd_echo} Starting Ops
  ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_ops_ms}"

  ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_sleep} ${_sleep}"

done