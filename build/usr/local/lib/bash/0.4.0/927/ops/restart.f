927.ops.restart () {
  # description
  # restarts ops engine
  # accepts 0 arguments

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # arguments variables


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # restart variables
  local _pid=



  # main
  if [[ $( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" | ${cmd_jq} -c '.[]' | wc -l ) == 0 ]]; then
    ${cmd_naemon} --daemon ${path_confd}/etc/naemon/naemon.cfg
    _exit_code=${exit_ok}
    _exit_string="Starting Ops"

  else
    _pid=$( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" | ${cmd_jq} -r '.pid' )
    ${cmd_kill} -HUP ${_pid}
    _exit_code=${exit_ok}
    _exit_string="Restarting Ops"

  fi


  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}