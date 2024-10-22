927.ops.commands.create () {

  # local variables
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done


  ## main
  if [[ ! -z ${_json} ]] && [[ -d ${_path} ]]; then
    ${cmd_rm} -rf ${_path}/*
    for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _command_line=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.line' )
      _command_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

      ${cmd_echo} Writing Command: ${_path}/${_command_name}.cfg
      ${cmd_cat} << EOF.command > ${_path}/${_command_name}.cfg

## these have to be left justified
define command                      {
  command_line                      ${_command_line}
  command_name                      ${_command_name}
}
EOF.command
## endl left justification

  done 
}








927.ops.config.running.get () {
  # local variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done
  #variables

  # main
  ## make path if not present
  if [[ ! -d ${_path} ]]; then
    ${cmd_mkdir} -p ${_path} 2>&1 > /dev/null
    ${cmd_chown} naemon:naemon ${_path}
    ${cmd_chmod} 660 ${_path}
  fi

  if [[ ! -f ${_path}/running.json ]]; then
    _exit_code=${exit_crit}
    _exit_string="{}"
  else
    _exit_code=${exit_crit}
    _exit_string=$( ${cmd_cat} ${_path}/running.json | ${cmd_jq} -c )

  # exit

}


















927.ops.hosts.cloud.create () {

  # local variables
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done

  ${cmd_rm} -rf ${_path}/*
  for cloud in $( ${cmd_echo} ${_json}  | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
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

    ${cmd_echo} Writing Host/Cloud: ${_path}/${_alias}.cfg
    ${cmd_cat} << EOF.cloud > ${_path}/${_alias}.cfg
define host                         {
  address                           ${_address}
  alias                             ${_alias}
  host_name                         ${_host_name}
  hostgroups                        ${_hostgroups}
  use                               cloud-infrastructure
}
EOF.cloud
  done

}

927.ops.paths.create () {
  # local variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _error_count=0
  local _json=
  local _path=


  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done  


  if [[ ! -z ${_json} ]] && [[ -d ${_path} ]]; then
    for path in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.[] | select(.enable == true).name' ); do 

      if [[ -d ${confd_path}/${path} ]]; then
        _exit_string="Writing Path(${confd_path}/${path}): Exists"

      else
        ${cmd_mkdir} ${confd_path}/${path}

        if [[ ${?} ]]; then
          _exit_string="Writing Path(${confd_path}/${path}): Success"
        
        else
          _exit_string="Writing Path(${confd_path}/${path}): Failure"
          (( _error_count++ ))
        
        fi
      fi

    done
  fi

  ${cmd_echo} ${_exit_string}
  [[ ${_error_count} > 0 ]] && return ${exit_warn} || return ${exit_ok}
}


927.ops.hosts.servers.create () {

  # local variables
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done  
    
  ${cmd_rm} -rf ${_path}/*
  for server in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
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

    ${cmd_echo} Writing Host/Server: ${_path}/${_alias}.cfg
    ${cmd_cat} << EOF.server > ${_path}/${_alias}.cfg
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
}


927.ops.restart () {

  # local variables
  local _json_candidate=
  
  local _json_running=
  local _pid=

  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json_running="${1}"
      ;;
      -jc | --json-candidate )
        shift
        _json_candidate=${1}
    esac
    shift
  done  

  # main
  case $( 927.ops.validate -j ${_json} -jc ${_json_candidate} 2>&1 /dev/null ) in
    ${exit_ok} )
      _exit_string="No Configuration Change"
      _exit_code=${exit_ok}
    ;;
    ${exit_warn} )
      _pid=$( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" | ${cmd_jq} -r '.pid' )
      ${cmd_kill} -HUP ${_pid}

      if [[ ${?} == ${exit_ok} ]]; then
        _exit_string="Restart - Success"
        _exit_code=${exit_warn}
        ${cmd_echo} ${_json} > ${running_conf}
      
      else
        _exit_string="Restart - Failure"
        _exit_code=${exit_crit}
      fi
    ;;
    ${exit_crit} )
      _exit_string="Syntax Error"
      _exit_code=${exit_crit}
    ;;
    ${exit_unkn} )
      _exit_string="Unknown problem"
      _exit_code=${exit_crit}
    ;;
  esac

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}

927.ops.validate () {

  # local variables
  local _json_candidate=
  local _json_candidate_hash=
  
  local _json_running=
  local _json_running_hash=

  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json_running="${1}"
      ;;
      -jc | --json-candidate )
        shift
        _json_candidate=${1}
    esac
    shift
  done  

  # main
  if [[ ! -z ${_json_running} ]] && [[ ! -z ${_json_candidate} ]]; then
    _json_running_hash=$( ${cmd_cat}  ${_json_running} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )
    _json_candidate_hash=$( ${cmd_cat}  ${_json_candidate} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )


    if [[ ${_json_running_hash} == ${_json_candidate_hash} ]]; then
      _exit_code=${exit_ok}
      _exit_string="No change in configuration"

    else
      ${cmd_naemon} -v ${confd_path}/naemon.cfg
      if [[ ${?} == ${exit_ok} ]]; then
        _exit_code=${exit_warn}
        _exit_string="Change in configuration"

      else
        _exit_code=${exit_crit}
        _exit_string="Change in configuration - failed validation"

      fi
    fi

  else
    _exit_code=${exit_crit}
    _exit_string="JSoN Running or Candidate not provided"

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}