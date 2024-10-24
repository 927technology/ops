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