927.ops.validate () {
  # description
  # validates ops configuraton
  # accepts 2 arguments -
  ## -p/--path  path to naemon conf file

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _path=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # validate variables
  

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p | --path )
        shift
        _path="${1}"
      ;;
    esac
    shift
  done  

  # main
  if [[ ! -z ${_path} ]]; then
    ${cmd_naemon} -v ${_path}/naemon.cfg 1> /dev/null 2> /dev/null
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