#!/bin/bash

# bools
false=0
true=1

# naemon exits
exit_crit=2
exit_ok=0
exit_unkn=3
exit_warn=1

# commands
cmd_awk=/bin/awk
cmd_cat=/bin/cat
cmd_chown=/bin/chown
cmd_chmod=/bin/chmod
cmd_curl=/bin/curl
cmd_echo=/bin/echo
cmd_jq=/bin/jq
cmd_mkdir=/bin/mkdir
cmd_rm=/bin/rm
cmd_sha256sum=/bin/sha256sum

# variables
_927conf_path=/etc/927
_address=
_alias=
_command_line=
_command_name=
_confd_path=/etc/naemon/conf.d
_exit_code=${exit_unkn}
_exit_string=
_file=../etc/naemon/naemon.json
_host_name=
_hostgroups=
_hostgroup_alias=
_hostgroup_name=
_url=https://raw.githubusercontent.com/927technology/ops/refs/heads/0.1.0/build/etc/927/ops.json

_json=
_json_running=/etc/927/running.json
_json_running_hash=
_json_candidate=$( ${cmd_curl} -s ${_url} | ${cmd_jq} -c 2> /dev/null)
_json_candidate_hash=$( ${cmd_echo} ${_json_candidate} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null)

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





  ## hosts/clouds
  ${cmd_rm} -rf ${_confd_path}/hosts/clouds/*
  for cloud in $( ${cmd_echo} ${_json}  | ${cmd_jq} -c '.hosts.clouds[] | select(.enable == true)' ); do 
    _address=$( ${cmd_echo} ${cloud}    | ${cmd_jq} -r '.address' )
    _alias=$( ${cmd_echo} ${cloud}      | ${cmd_jq} -r '.alias' )
    _host_name=$( ${cmd_echo} ${cloud}  | ${cmd_jq} -r '.host_name' )
    _hostgroups=
    _hostgroups_count=0

    for hostgroup in $( ${cmd_echo} ${cloud} | ${cmd_jq} -r '.hostgroups[] | select(.enable == true) | .name' ); do 

      if [[ ${_hostgroups_count} > 0 ]]; then
        _hostgroups+=,
      fi

      (( _hostgroups_count++ ))
      _hostgroups+=${hostgroup}
    done

    ${cmd_echo} Writing Host/Cloud: ${_confd_path}/hosts/clouds/${_alias}.cfg
    ${cmd_cat} << EOF.cloud > ${_confd_path}/hosts/clouds/${_alias}.cfg
define host                         {
  address                           ${_address}
  alias                             ${_alias}
  host_name                         ${_host_name}
  hostgroups                        ${_hostgroups}
  use                               cloud-infrastructure
}
EOF.cloud
  done



  ## commands
  ${cmd_rm} -rf ${_confd_path}/commands/*
  for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.commands[] | select(.enable == true)' ); do 
    _command_line=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.line' )
    _command_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

    ${cmd_echo} Writing Command: ${_confd_path}/commands/${_command_name}.cfg
    ${cmd_cat} << EOF.command > ${_confd_path}/commands/${_command_name}.cfg
define command                      {
  command_line                      ${_command_line}
  command_name                      ${_command_name}
}
EOF.command
  done




  ## hosts/servers
  ${cmd_rm} -rf ${_confd_path}/hosts/servers/*
  for server in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.hosts.servers[] | select(.enable == true)' ); do 
    _address=$( ${cmd_echo} ${server}   | ${cmd_jq} -r '.address' )
    _alias=$( ${cmd_echo} ${server}     | ${cmd_jq} -r '.alias' )
    _host_name=$( ${cmd_echo} ${server} | ${cmd_jq} -r '.host_name' )
    _hostgroups=
    _hostgroups_count=0

    for hostgroup in $( ${cmd_echo} ${server} | ${cmd_jq} -r '.hostgroups[] | select(.enable == true) | .name' ); do 

      if [[ ${_hostgroups_count} > 0 ]]; then
        _hostgroups+=,
      fi

      (( _hostgroups_count++ ))
      _hostgroups+=${hostgroup}
    done

    ${cmd_echo} Writing Host/Server: ${_confd_path}/hosts/servers/${_alias}.cfg
    ${cmd_cat} << EOF.server > ${_confd_path}/hosts/servers/${_alias}.cfg
define host                         {
  address                           ${_address}
  alias                             ${_alias}
  host_name                         ${_host_name}
  hostgroups                        ${_hostgroups}
  use                               cloud-infrastructure

  _cpus
  _storage
}
EOF.server
  done
fi





# exit

${cmd_echo} ${_exit_string}
exit ${_exit_code}