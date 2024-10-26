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
  if [[ ! -z ${_json} ]] && [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then
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