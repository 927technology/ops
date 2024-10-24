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