#!/bin/bash

# because IFS sucks
IFS=$'\n'

# library root
export _lib_root=/usr/local/lib/bash/${LIB_VERSION}

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
  ${cmd_echo} New Candidate Configuration Detected
  

  # contacts
  ${cmd_echo} contacts
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.contacts' )
  927.ops.create.contacts -j "${_json}" -p ${_path_confd}/contacts
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # contactgroups
  ${cmd_echo} contact groups
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.contactgroups' )
  927.ops.create.contactgroups -j "${_json}" -p ${_path_confd}/contactgroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # commands
  ${cmd_echo} commands
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.commands' )
  927.ops.create.commands -j "${_json}" -p ${_path_confd}/commands
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/clouds
  ${cmd_echo} hosts/clouds
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.clouds' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/clouds
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/printers
  ${cmd_echo} hosts/printers
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.printers' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/printers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/routers
  ${cmd_echo} hosts/routers
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.routers' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/routers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/servers
  ${cmd_echo} hosts/servers
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.servers' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/servers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/switches
  ${cmd_echo} hosts/switches
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.switches' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/switches
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/wireless
  ${cmd_echo} hosts/wireless
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hosts.wiereless' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/wireless
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # hostgroups
  ${cmd_echo} hostgroups
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.hostgroups' )
  927.ops.create.hostgroups -j "${_json}" -p ${_path_confd}/hostgroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # services
  ${cmd_echo} services
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.services' )
  927.ops.create.services -j "${_json}" -p ${_path_confd}/services
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # servicegroups
  ${cmd_echo} servicegroups
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.servicegroups' )
  927.ops.create.servicegroups -j "${_json}" -p ${_path_confd}/servicegroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # servicedependencies
  ${cmd_echo} servicedependencies
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.servicedependencies' )
  927.ops.create.servicedependencies -j "${_json}" -p ${_path_confd}/servicedependencies
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # serviceescalations
  ${cmd_echo} serviceescalations
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.serviceescalations' )
  927.ops.create.servicedependencies -j "${_json}" -p ${_path_confd}/serviceescalations
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # timeperiods
  ${cmd_echo} timeperiods
  _json=$( ${cmd_echo} "${_json_candidate}" | ${cmd_jq} -c '.timeperiods' )
  927.ops.create.timeperiods -j "${_json}" -p ${_path_confd}/timeperiods
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo}



  ${cmd_echo} templates/contacts
  # templates/contacts
  _json=$( ${cmd_echo} "${_json_configuration}" | ${cmd_jq} -c '.templates.contacts' )
  927.ops.create.contacts -j "${_json}" -p ${_path_confd}/templates/contacts -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  ${cmd_echo} templates/hosts
  # templates/hosts
  _json=$( ${cmd_echo} "${_json_configuration}" | ${cmd_jq} -c '.templates.hosts' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/templates/hosts -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  ${cmd_echo} templates/hostgroups
  # templates/hostgroups
  _json=$( ${cmd_echo} "${_json_configuration}" | ${cmd_jq} -c '.templates.hostgroups' )
  927.ops.create.hostgroups -j "${_json}" -p ${_path_confd}/templates/hostgroups -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  ${cmd_echo} templates/servers
    # templates/servers
  _json=$( ${cmd_echo} "${_json_configuration}" | ${cmd_jq} -c '.templates.servers' )
  927.ops.create.hosts -j "${_json}" -p ${_path_confd}/templates/servers -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

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


