#!/bin/bash

# config
. /usr/etc/927/ops.cfg

# source
. /usr/local/lib/bash/${lib_version}/927/cmd_el.v
. /usr/local/lib/bash/${lib_version}/927/bools.v
. /usr/local/lib/bash/${lib_version}/927/nagios.v
. /usr/local/lib/bash/${lib_version}/927/ops.f

# variables
_address=
_alias=
_command_line=
_command_name=
_exit_code=${exit_unkn}
_exit_string=
_host_name=
_hostgroups=
_hostgroup_alias=
_hostgroup_name=
_json=
_json_running=/etc/927/running.json
_json_running_hash=
_json_candidate=$( ${cmd_curl} -s ${_url} | ${cmd_jq} -c 2> /dev/null)
_json_candidate_hash=$( ${cmd_echo} ${_json_candidate} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null)
_json_naemon_processes="{}"
_naemon_processes_count=0
_naemon_pid=
_nameon_confd=/etc/naemon/conf.d


# source

# main
IFS=$'\n'

## 927 conf dir
if [[ ! -d ${_927_conf_path} ]]; then
  ${cmd_mkdir} -p ${_927conf_path} 2> /dev/null
  ${cmd_chown} naemon:naemon ${_927conf_path}
  ${cmd_chmod} 660 ${_927conf_path}
fi

## get running config hash
if [[ -f ${_json_running} ]]; then
  _json_hash_running=$( ${cmd_cat} ${_json_running} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
fi

_json_running_hash=$( ${cmd_cat}  ${_json_running} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )


if [[ ${_json_running_hash} == ${_json_candidate_hash} ]]; then
  _exit_code=${exit_ok}
  _exit_string="No change in configuration"

else
  _exit_code=${exit_warn}
  _exit_string="Change in configuration"
  ${cmd_echo} ${_json_candidate} > ${_json_running}
  _json=${_json_candidate}

  ## hostgroups
  ${cmd_rm} -rf ${_confd_path}/hosts/hostgroups/*
  for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.hostgroups[] | select(.enable == true)' ); do 
    _hostgroup_alias=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.alias' )
    _hostgroup_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

    ${cmd_echo} Writing Host Group: ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
    ${cmd_cat} << EOF.hostgroup > ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
define hostgroup                    {
  alias                             ${_hostgroup_alias}
  hostgroup_name                    ${_hostgroup_name}
}
EOF.hostgroup
  done




  ## commands
  927.ops.commands.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.commands' ) -p ${_nameon_confd}/commands

  ## hosts/clouds
  927.ops.hosts.cloud.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.hosts.clouds' ) -p ${_nameon_confd}/hosts/clouds 

  ## hosts/servers
  927.ops.hosts.servers.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.hosts.servers' ) -p ${_nameon_confd}/hosts/servers




_json_naemon_processes=$( ${cmd_osqueryi} "select name, cmdline, pid, parent from processes where name='naemon'" --json )
_naemon_processes_count=$( ${cmd_echo} ${_json_naemon} | ${cmd_jq} '.[] | select(.cmdline | contains("daemon"))' | ${cmd_jq} -s | ${_cmd_jq} '. | length' )



if [[ ${_naemon_processes_count} > 0 ]] && [[ ${_exit_code} != ${exit_ok} ]]; then
  ${cmd_naemon} --verify-config /etc/naemon/naemon.cfg 2>&1 > /dev/null
  if [[ ${?} ]]
    _naemon_pid=$( ${cmd_echo} ${_json_naemon} | ${cmd_jq} -r '.[0].pid' )
    ${cmd_kill} -HUP naemon
  fi
else
  /usr/bin/naemon --daemon /etc/naemon/naemon.cfg
fi

# exit

${cmd_echo} ${_exit_string}
exit ${_exit_code}


## to do - write output messages and codes for restart or failed