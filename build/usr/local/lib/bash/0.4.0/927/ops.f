927.ops.config.new () {
    # description
  # validates ops configuraton
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _json_candidate=
  local _json_candidate_hash=
  
  local _json_running=
  local _json_running_hash=

  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json_running="${1}"
      ;;
      -jc | --json-candidate )
        shift
        _json_candidate="${1}"
    esac
    shift
  done  

  # main
  if [[ ! -z ${_json_running} ]] && [[ ! -z ${_json_candidate} ]]; then
    _json_running_hash=$( ${cmd_echo}  "${_json_running}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )
    _json_candidate_hash=$( ${cmd_echo}  "${_json_candidate}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )


    if [[ ${_json_running_hash} == ${_json_candidate_hash} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${false}

    else
        _exit_code=${exit_warn}
        _exit_string=${true}

    fi

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}

927.ops.config.running.get () {
  # description
  # gets the running config for the ops monitor and returns to calling function
  # accepts 1 argument 
  ## -p/--path which is the full path to the configuration file.

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p | --path )
        shift
        _path=${1}
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${_path} ]] && [[ $( json.validate -j ${_json} ) == ${true} ]]; then

    ## make path if not present
    if [[ ! -d ${_path} ]]; then
      ${cmd_mkdir} -p ${_path} 1> /dev/null 2> /dev/null
    fi

    # set group/owner and mode
    ${cmd_chown} naemon:naemon ${_path}
    ${cmd_chmod} 660 ${_path}


    if [[ ! -f ${_path}/running.json ]]; then
      _exit_code=${exit_crit}
      _json="{}"
    
    else
      _json=$( ${cmd_cat} ${_path}/running.json | ${cmd_jq} -c )

    fi

  else
    _exit_code=${exit_crit}
    _exit_string="{}"

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}



927.ops.create.commands () {
  # description
  # creates ops commands stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _name=
  local _line=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; do
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
  if [[ ! -z ${_json} ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*

    for command in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _line=$( ${cmd_echo} "${command}"| ${cmd_jq} -r '.line' )
      _name=$( ${cmd_echo} "${command}"| ${cmd_jq} -r '.name' )

      ${cmd_echo} Writing Command: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.command > ${_path}/${_name}.cfg

define command                      {
  command_line                      ${_line}
  command_name                      ${_name}
}
EOF.command

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}
  fi
}


927.ops.create.hosts () {
  # description
  # creates ops hosts stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _address=
  local _alias=
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _host_name=
  local _hostgroups=
  local _hostgroups_count=
  local _json=
  local _name=
  local _line=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; do
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
  if [[ ! -z ${_json} ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*
    
    for host in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _address=$( ${cmd_echo} ${host}   | ${cmd_jq} -r '.address' )
      _alias=$( ${cmd_echo} ${host}     | ${cmd_jq} -r '.alias' )
      _host_name=$( ${cmd_echo} ${host} | ${cmd_jq} -r '.host_name' )
      _hostgroups=
      _hostgroups_count=0

      for hostgroup in $( ${cmd_echo} ${host} | ${cmd_jq} -r '.hostgroups[] | select(.enable == true) | .name' ); do 

        if [[ ${_hostgroups_count} > 0 ]]; then
          _hostgroups+=,
        fi

        (( _hostgroups_count++ ))
        _hostgroups+=${hostgroup}
      done

      ${cmd_echo} Writing Host: ${_path}/${_alias}.cfg
      ${cmd_cat} << EOF.host > ${_path}/${_alias}.cfg
define host                         {
  address                           ${_address}
  alias                             ${_alias}
  host_name                         ${_host_name}
  hostgroups                        ${_hostgroups}
  use                               cloud-infrastructure

  _cpus
  _storage
}
EOF.host

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}
  fi
}

927.ops.create.hostgroups () {
  # description
  # creates ops hosts group stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _alias=
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _name=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; do
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
  if [[ ! -z ${_json} ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*
    
    for hostgroup in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _alias=$( ${cmd_echo} ${hostgroup} | ${cmd_jq} -r '.alias' )
      _name=$( ${cmd_echo} ${hostgroup} | ${cmd_jq} -r '.name' )



      ${cmd_echo} Writing Host Group: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.hostgroup > ${_path}/${_name}.cfg
define hostgroup                    {
  hostgroup_name	                  ${_name}
  alias	                            ${_alias}
}
EOF.hostgroup

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}
  fi
}



927.ops.restart () {
  # description
  # creates ops commands stanzas based on json configuration provided
  # accepts 0 arguments

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # local variables
  local _json_candidate=
  
  local _json_running=
  local _pid=

  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
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
  # description
  # validates ops configuraton
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # local variables
  local _json_candidate=
  local _json_candidate_hash=
  
  local _json_running=
  local _json_running_hash=

  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json_running="${1}"
      ;;
      -jc | --json-candidate )
        shift
        _json_candidate="${1}"
    esac
    shift
  done  

  # main
  if [[ ! -z ${_json_running} ]] && [[ ! -z ${_json_candidate} ]]; then
    _json_running_hash=$( ${cmd_echo}  "${_json_running}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )
    _json_candidate_hash=$( ${cmd_echo}  "${_json_candidate}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )


    if [[ ${_json_running_hash} == ${_json_candidate_hash} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${true}

    else
      ${cmd_naemon} -v ${confd_path}/naemon.cfg 1> /dev/null 2> /dev/null
      if [[ ${?} == ${exit_ok} ]]; then
        _exit_code=${exit_warn}
        _exit_string=${true}

      else
        _exit_code=${exit_crit}
        _exit_string=${false}

      fi
    fi

  else
    _exit_code=${exit_crit}
    _exit_string=${false}

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}