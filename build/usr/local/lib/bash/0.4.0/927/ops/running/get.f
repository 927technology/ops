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
  if [[ -f ${_path} ]] && [[ $( json.validate -j "$( ${cmd_cat} ${_path} )" ) == ${true} ]]; then
    _json=$( ${cmd_cat} ${_path} | ${cmd_jq} -c )
    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
      _exit_string="${_json}"
    else
      _exit_code=${exit_crit}
      _exit_string="{}"
    fi

  else
    _exit_code=${exit_warn}
    _exit_string="{}"

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}