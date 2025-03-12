#!/bin/bash

# library root
export _lib_root=/usr/local/lib/bash/${LIB_VERSION}

# source libraries
. ${_lib_root}/927/variables/cmd_el.v
. ${_lib_root}/927/variables.l
. ${_lib_root}/927/date.l
. ${_lib_root}/json.l
. ${_lib_root}/927/ops.l
. ${_lib_root}/927/secretservice.l

# local cmd
cmd_ops_ms=/usr/local/bin/ms.sh

# variables
_sleep=60

# main
if [[ "${MANAGEMENT}" == "true" ]]; then
  ${cmd_echo}
  ${cmd_echo} Starting Job Server
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/sbin/gearmand -d --log-file none --syslog $OPTIONS"
  




  # if [[ ! -f ~naemon/secrets/ops.927.technology.cert ]] && [[ ! -f ~naemon/secrets/ops.927.technology.key ]]; then
  #   openssl req                                                               \
  #     -days   3650                                                            \
  #     -keyout ~naemon/secrets/ops.927.technology.key                          \
  #     -newkey rsa:2048                                                        \
  #     -nodes                                                                  \
  #     -subj   "/C=US/ST=MS/L=Gulfport/O=927 Technology/CN=ops.927.technology" \
  #     -out    ~naemon/secrets/ops.927.technology.cert                         \
  #     -x509
  # fi



  # generate tls cert
  ${cmd_echo} Pulling Web TLS Cert
  927.secretservice.get.tlscert --group apache --owner apache --path ~apache --secrets-provider bitwarden 

  # start weeb server
  ${cmd_echo} Starting Web Interface
  ${cmd_httpd} -DBACKGROUND 2>/dev/null
fi

if [[ "${WORKER}" == "true" ]]; then
  # start gearman worker
  ${cmd_echo} Starting Gearman Worker
  ${cmd_su} naemon --login --shell=/bin/sh "--command=/usr/bin/mod_gearman_worker -d --config=/etc/mod_gearman/worker.conf"
fi

# poll the API
while [[ ${true} == ${true} ]]; do
  if [[ ${WORKER} == "true" ]]; then
    # generate ~/.oci/config
    ${cmd_echo} Pulling OCI Config
    927.secretservice.get.ociconfig   --group naemon --owner naemon --path ~naemon --secrets-provider bitwarden
    
    # generate ~/secrets/keyfile.pem
    ${cmd_echo} Pulling OCI PEM
    927.secretservice.get.ocikeyfile  --group naemon --owner naemon --path ~naemon --secrets-provider bitwarden
  fi

  if [[ ${MANAGEMENT} == "true" ]]; then
    ${cmd_echo} Starting Ops
    ${cmd_echo}
    ${cmd_su} naemon --login --shell=/bin/sh "--command=${cmd_ops_ms}"
  fi

  ${cmd_echo}
  ${cmd_sleep} ${_sleep}
  ${cmd_echo} ----------------------------------------------------------
done