#!/bin/bash

# because IFS sucks
IFS=$'\n'

# library root
_lib_root=/usr/local/lib/bash/${LIB_VERSION}

# source libraries
. ${_lib_root}/927/variables.l
. ${_lib_root}/927/ops.l
. ${_lib_root}/json.l


# configuration variables
_json_candidate=$( ${cmd_curl} -s ${URL}/candidate.json | ${cmd_jq} -c )
_json_configuration=$( ${cmd_curl} -s ${URL}/config.json | ${cmd_jq} -c )
_json_running=$( 927.ops.config.running.get )



# validate json
_json_candidate_validate=$( json.validate -j ${_json_candidate} || exit -1)
_json_configuration_validate=$( json.validate -j ${_json_configuration} || exit -1)
_json_running_validate=$( json.validate -j ${_json_running} || exit -1)



# variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=
_json=
_path_927=$( ${cmd_echo} ${_json_configuration}     | ${cmd_jq} -r '.configuration.paths."927"' )
_path_confd=$( ${cmd_echo} ${_json_configuration}   | ${cmd_jq} -r '.configuration.paths.confd' )
_path_naemon=$( ${cmd_echo} ${_json_configuration}  | ${cmd_jq} -r '.configuration.paths.naemon' )


# main
if [[ $( 927.ops.config.new -j ${_json_running} -jc ${_json_candidate} ) ]]; then
  ${cmd_echo} New Configuration Detected
  
  # commands
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.commands' )
  927.ops.create.commands -j "${_json}" -p ${_path_confd}/commands
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=

  # hosts/clouds
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.clouds' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/clouds
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=

  # hosts/servers
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.servers' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/servers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=

  # hostgroups
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hostgroups' )
  927.ops.create.hostgroups -j "${_json}" -p ${_path_confd}/hostgroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=

fi

















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


