#!/bin/bash

# because IFS sucks
IFS=$'\n'

clear
date
# source config
. /usr/local/etc/ops/management.cfg


# library root
export _lib_root=/usr/local/lib/bash/${LIB_VERSION}

# source libraries
. ${_lib_root}/927/variables.l
. ${_lib_root}/927/ops.l
. ${_lib_root}/json.l


# variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=
_json=
_configuration_changes=0


# configuration variables
_json_configuration_candidate=$( ${cmd_curl} -s ${URL}/configuration.json | ${cmd_jq} -c )
_json_configuration_running=$( 927.ops.config.running.get -p  ${path_927}/configuration.json )
_json_infrastructure_candidate=$( ${cmd_curl} -s ${URL}/infrastructure.json | ${cmd_jq} -c )
_json_infrastructure_running=$( 927.ops.config.running.get -p  ${path_927}/infrastructure.json )


# validate json
_json_configuration_candidate_validate=$( json.validate -j ${_json_configuration_candidate} || exit -1)
_json_configuration_running_validate=$( json.validate -j ${_json_configuration_running} || exit -1)
_json_infrastructure_candidate_validate=$( json.validate -j ${_json_infrastructure_candidate} || exit -1)
_json_infrastructure_running_validate=$( json.validate -j ${_json_infrastructure_running} || exit -1)


# main
[[ ! -d ${path_927} ]] && ${cmd_mkdir} -p ${path_927}

echo ----------------
927.ops.config.new -j ${_json_configuration_running} -jc ${_json_configuration_candidate}
echo $?
echo ===============

# write configuration to file
if [[ ! $( 927.ops.config.new -j ${_json_configuration_running} -jc ${_json_configuration_candidate} ) ]]   && \
   [[ ${_json_configuration_candidate_validate} == ${true} ]]; then
  ${cmd_echo} New Candidate Configuration Detected
  ${cmd_echo} ----------------------------------------------------------


  # contacts
  ${cmd_echo} contacts
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.contacts' )
  927.ops.create.contacts -j "${_json}" -p ${path_confd}/contacts
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # contactgroups
  ${cmd_echo} contact groups
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.contactgroups' )
  927.ops.create.contactgroups -j "${_json}" -p ${path_confd}/contactgroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # commands
  ${cmd_echo} commands
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.commands' )
  927.ops.create.commands -j "${_json}" -p ${path_confd}/commands
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 



  # hostgroups
  ${cmd_echo} hostgroups
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.hostgroups' )
  927.ops.create.hostgroups -j "${_json}" -p ${path_confd}/hostgroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 



  # services
  ${cmd_echo} services
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.services' )
  927.ops.create.services -j "${_json}" -p ${path_confd}/services
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # servicegroups
  ${cmd_echo} servicegroups
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.servicegroups' )
  927.ops.create.servicegroups -j "${_json}" -p ${path_confd}/servicegroups
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # servicedependencies
  ${cmd_echo} servicedependencies
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.servicedependencies' )
  927.ops.create.servicedependencies -j "${_json}" -p ${path_confd}/servicedependencies
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # serviceescalations
  ${cmd_echo} serviceescalations
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.serviceescalations' )
  927.ops.create.servicedependencies -j "${_json}" -p ${path_confd}/serviceescalations
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # templates/contacts
  ${cmd_echo} templates/contacts
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.contacts' )
  927.ops.create.contacts -j "${_json}" -p ${path_confd}/templates/contacts -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # templates/hosts
  ${cmd_echo} templates/hosts
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.hosts' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/templates/hosts -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # templates/hostgroups
  ${cmd_echo} templates/hostgroups
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.hostgroups' )
  927.ops.create.hostgroups -j "${_json}" -p ${path_confd}/templates/hostgroups -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


    # templates/servers
  ${cmd_echo} templates/servers
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.servers' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/templates/servers -t
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo}


  # timeperiods
  ${cmd_echo} timeperiods
  _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.timeperiods' )
  927.ops.create.timeperiods -j "${_json}" -p ${path_confd}/timeperiods
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 


  # output json to file
  ${cmd_echo} "${_json_configuration_candidate}" > ${path_927}/configuration.json

  # increment changes
  (( _configuration_changes++ ))

else
  ${cmd_echo} New Candidate Configuration Not Detected
  ${cmd_echo} ----------------------------------------------------------
fi

${cmd_echo} ==========================================================
${cmd_echo}
${cmd_echo}


# write infrastructure to file
if [[ ! $( 927.ops.config.new -j ${_json_infrastructure_running} -jc ${_json_infrastructure_candidate} ) ]] && \
   [[ ${_json_infrastructure_candidate_validate} == ${true} ]]; then
  ${cmd_echo} New Candidate Infrastructure Configuration Detected
  ${cmd_echo} ----------------------------------------------------------


  

  # hosts/clouds
  ${cmd_echo} hosts/clouds
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.clouds' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/clouds
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/printers
  ${cmd_echo} hosts/printers
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.printers' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/printers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/routers
  ${cmd_echo} hosts/routers
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.routers' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/routers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/servers
  ${cmd_echo} hosts/servers
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.servers' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/servers
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/switches
  ${cmd_echo} hosts/switches
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.switches' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/switches
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 

  # hosts/wireless
  ${cmd_echo} hosts/wireless
  _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.wiereless' )
  927.ops.create.hosts -j "${_json}" -p ${path_confd}/hosts/wireless
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
  _json=
  ${cmd_echo} 



  # output json to file
  ${cmd_echo} "${_json_configuration_candidate}" > ${path_927}/infrastructure.json

  # increment changes
  (( _configuration_changes++ ))

else
  ${cmd_echo} New Candidate Infrastructure Configuration Not Detected
  ${cmd_echo} ----------------------------------------------------------

fi

${cmd_echo} ==========================================================
${cmd_echo}
${cmd_echo}


if [[ ${_configuration_changes} > 0 ]]; then
  ${cmd_echo} Validating Configuration

  927.ops.validate -p ${path_naemon} 1> /dev/null 2> /dev/null

  if [[ ${?} == ${exit_ok} ]]; then
    ${cmd_echo} Validation Successfull

    927.ops.restart

  else
    ${cmd_echo} Validation Unsuccessfull

  fi

else
  ${cmd_echo} No New Configuration Detected

fi