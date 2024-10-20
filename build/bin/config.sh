#!/bin/bash

# commands
cmd_cat=/bin/cat
cmd_echo=/bin/echo
cmd_jq=/bin/jq
cmd_rm=/bin/rm

# variables
_address=
_alias=
_command_line=
_command_name=
_confd_path=../etc/naemon/conf.d
_file=../etc/naemon/naemon.json
_host_name=
_hostgroups=
_hostgroup_alias=
_hostgroup_name=
_json=$( ${cmd_cat} ${_file}          | ${cmd_jq} -c )

# main
IFS=$'\n'



## hostgroups
${cmd_rm} -rf ${_confd_path}/hosts/hostgroups/*
for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.hostgroups[] | select(.enable == true)' ); do 
  _hostgroup_alias=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.alias' )
  _hostgroup_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

  ${cmd_echo} Writing Host Group: ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
  ${cmd_cat} << EOF.hostgroup > ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
define hostgroup                    {
  hostgroup_alias                   ${_hostgroup_alias}
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