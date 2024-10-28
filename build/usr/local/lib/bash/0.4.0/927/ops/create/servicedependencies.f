927.ops.create.servicedependencies () {
  # description
  # creates ops service dependency stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path
  ## -t/--template if this will be a template or a configuraton.  sets the register option.

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _json=
  local _path=
  local _template=${false}


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # service dependancy variables
  local _dependency_period=
  local _dependent_host_name=
  local _dependent_hostgroup_name=
  local _dependent_servicegroup_name=


  # local _dependent_service_description=
  local _execution_failure_criteria=
  local _file_name=
  local _host_name=
  local _inherits_parent=
  local _hostgroup_name=
  local _notification_failure_criteria=
  local _servicegroup_name=
  local _service_description=

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
      ;;
      -t | --template )
        _template=${true}
      ;;
    esac
    shift
  done

  ## main
  if [[ ! -z ${_json} ]] && [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*

    for servicedependancy in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _dependency_period=$(             ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '.dependant.timeperiod.string | select( .dependant.timeperiod.enable == true )' )
      _dependent_host_name=$(           ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .dependant.hosts[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _dependent_hostgroup_name=$(      ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .dependant.hostgroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _dependent_servicegroup_name=$(   ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .dependant.servicegroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      # _dependent_service_description=
      _execution_failure_criteria=$(    ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .criteria | to_entries[] | select(.value == true) | .key[0:1] ] | if( . | length < 1 ) then "" else join(", ") end' )
      _file_name=$(                     ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.name.string' )
      _host_name=$(                     ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .hosts[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _hostgroup_name=$(                ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .hostgroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _inherits_parent=$(               ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.inherits_parent| if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _notification_failure_criteria=$( ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .notification_failure_criteria | to_entries[] | select(.value == true) | .key[0:1] ] | if( . | length < 1 ) then "" else join(", ") end' )
      _service_description=$(           ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '.service.string' )
      _servicegroup_name=$(             ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .servicegroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )


      ${cmd_echo} Writing Service Dependancy: ${_path}/${_file_name}.cfg
      ${cmd_cat} << EOF.servicedependency > ${_path}/${_file_name}.cfg
define servicedependency              {
$( [[ ! -z ${_dependency_period} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" dependency_period "${_dependency_period}" )
$( [[ ! -z ${_dependent_host_name} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" dependent_host_name "${_dependent_host_name}" )
$( [[ ! -z ${_dependent_hostgroup_name} ]]      && ${cmd_printf} '%-1s %-32s %-50s' "" dependent_hostgroup_name "${_dependent_hostgroup_name}" )
$( [[ ! -z ${_dependent_servicegroup_name} ]]   && ${cmd_printf} '%-1s %-32s %-50s' "" dependent_servicegroup_name "${_dependent_servicegroup_name}" )
$( [[ ! -z ${_execution_failure_criteria} ]]    && ${cmd_printf} '%-1s %-32s %-50s' "" execution_failure_criteria "${_execution_failure_criteria}" )
$( [[ ! -z ${_host_name} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" host_name "${_host_name}" )
$( [[ ! -z ${_hostgroup_name} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" hostgroup_name "${_hostgroup_name}" )
$( [[ ! -z ${_inherits_parent} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" inherits_parent "${_inherits_parent}" )
$( [[ ! -z ${_notification_failure_criteria} ]] && ${cmd_printf} '%-1s %-32s %-50s' "" notification_failure_criteria "${_notification_failure_criteria}" )
$( [[ ! -z ${_service_description} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" service_description "${_service_description}" )
$( [[ ! -z ${_servicegroup_name} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" servicegroup_name "${_servicegroup_name}" )
}
EOF.servicedependency

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^[[:space:]]*$/d' ${_path}/${_file_name}.cfg
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