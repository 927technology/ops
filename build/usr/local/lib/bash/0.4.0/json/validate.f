json.validate () {
  # local variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json=${1}
    esac
    shift
  done

  if [[ ! -z "${_json}" ]]; then
    ${cmd_echo} "${_json}" | ${cmd_jq} 1> /dev/null 2> /dev/null
    
    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${true}

    else
      _exit_code=${exit_crit}
      _exit_string=${false}

    fi
  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}