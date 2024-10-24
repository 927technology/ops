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