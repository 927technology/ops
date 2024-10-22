#!/bin/bash

# because IFS sucks
IFS=$'\n'

# source
. /usr/local/lib/bash/${LIB_VERSION}/json/validate.f
. /usr/local/lib/bash/${LIB_VERSION}/927/cmd_el.v
. /usr/local/lib/bash/${LIB_VERSION}/927/bools.v
. /usr/local/lib/bash/${LIB_VERSION}/927/nagios.v
. /usr/local/lib/bash/${LIB_VERSION}/927/ops.f


# configuration variables
_json_candidate=$( ${cmd_curl} -s ${URL}/candidate.json )
_json_configuration=$( ${cmd_curl} -s ${URL}/config.json )
_json_running=$( 927.ops.config.running.get )

# validate json
_json_candidate_validate=$( json.validate -j ${_json_candidate} || exit -1)
_json_configuration_validate=$( json.validate -j ${_json_configuration} || exit -1)
_json_running_validate=$( json.validate -j ${_json_running} || exit -1)



# variables
_exit_code=${exit_unkn}
_exit_string=
_path_927=$( ${cmd_echo} ${_json_configuration}     | ${cmd_jq} -r '.configuration.paths.927' )
_path_confd=$( ${cmd_echo} ${_json_configuration}   | ${cmd_jq} -r '.configuration.paths.confd' )
_path_naemon=$( ${cmd_echo} ${_json_configuration}  | ${cmd_jq} -r '.configuration.paths.naemon' )


# main
















#   ## hostgroups
#   ${cmd_rm} -rf ${_confd_path}/hosts/hostgroups/*
#   for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.hostgroups[] | select(.enable == true)' ); do 
#     _hostgroup_alias=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.alias' )
#     _hostgroup_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

#     ${cmd_echo} Writing Host Group: ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
#     ${cmd_cat} << EOF.hostgroup > ${_confd_path}/hosts/hostgroups/${_hostgroup_name}.cfg
# define hostgroup                    {
#   alias                             ${_hostgroup_alias}
#   hostgroup_name                    ${_hostgroup_name}
# }
# EOF.hostgroup
#   done




#   ## commands
#   927.ops.commands.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.commands' ) -p ${_nameon_confd}/commands

#   ## hosts/clouds
#   927.ops.hosts.cloud.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.hosts.clouds' ) -p ${_nameon_confd}/hosts/clouds 

#   ## hosts/servers
#   927.ops.hosts.servers.create -j $( ${cmd_echo} ${_json} | ${cmd_jq} '.hosts.servers' ) -p ${_nameon_confd}/hosts/servers




# _json_naemon_processes=$( ${cmd_osqueryi} "select name, cmdline, pid, parent from processes where name='naemon'" --json )
# _naemon_processes_count=$( ${cmd_echo} ${_json_naemon} | ${cmd_jq} '.[] | select(.cmdline | contains("daemon"))' | ${cmd_jq} -s | ${_cmd_jq} '. | length' )



# if [[ ${_naemon_processes_count} > 0 ]] && [[ ${_exit_code} != ${exit_ok} ]]; then
#   ${cmd_naemon} --verify-config /etc/naemon/naemon.cfg 2>&1 > /dev/null
#   if [[ ${?} ]]
#     _naemon_pid=$( ${cmd_echo} ${_json_naemon} | ${cmd_jq} -r '.[0].pid' )
#     ${cmd_kill} -HUP naemon
#   fi
# else
#   /usr/bin/naemon --daemon /etc/naemon/naemon.cfg
# fi

# # exit

# ${cmd_echo} ${_exit_string}
# exit ${_exit_code}


## to do - write output messages and codes for restart or failed