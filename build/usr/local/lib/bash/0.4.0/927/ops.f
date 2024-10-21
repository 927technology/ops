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