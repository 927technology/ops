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