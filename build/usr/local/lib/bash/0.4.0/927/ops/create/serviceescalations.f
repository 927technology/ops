927.ops.create.serviceescalations () {
  # description
  # creates ops service escalation stanzas based on json configuration provided
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
  local _contact_groups=
  local _contacts=
  local _escalation_period=
  local _escalation_options=
  local _first_notification=
  local _host_name=
  local _hostgroup_name=
  local _last_notification=
  local _notification_interval=
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

    for serviceescalation in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _contacts=$(              ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .contacts[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _contact_groups=$(        ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .contactgroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _escalation_options=$(    ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .escalation.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( . | length < 1 ) then "" else join(", ") end' )
      _escalation_period=$(     ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '.escalation.timeperiod.string | select( .escalation.timeperiod.enable == true )' )
      _file_name=$(             ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.name.string' )
      _first_notification=$(    ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.first_notification' )
      _host_name=$(             ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.name.string' )
      _hostgroup_name=$(        ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r  '[ .hostgroups[] | select( .enable == true ).string ] | if( . | length < 1 ) then "" else join(", ") end' )
      _last_notification=$(     ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.last_notificaton' )
      _notification_interval=$( ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.notification_interval' )
      _service_description=$(   ${cmd_echo} ${servicedependancy}  | ${cmd_jq} -r '.service_description' )


      ${cmd_echo} Writing Service Dependancy: ${_path}/${_file_name}.cfg
      ${cmd_cat} << EOF.servicedependency > ${_path}/${_file_name}.cfg
define servicedependency              {
$( [[ ! -z ${_contacts} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" contacts "${_contacts}" )
$( [[ ! -z ${_contact_groups} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" contact_groups "${_contact_groups}" )
$( [[ ! -z ${_escalation_options} ]]    && ${cmd_printf} '%-1s %-32s %-50s' "" escalation_options "${_escalation_options}" )
$( [[ ! -z ${_escalation_period} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" escalation_period "${_escalation_period}" )
$( [[ ! -z ${_first_notification} ]]    && ${cmd_printf} '%-1s %-32s %-50s' "" first_notification "${_first_notification}" )
$( [[ ! -z ${_host_name} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" host_name "${_host_name}" )
$( [[ ! -z ${_hostgroup_name} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" hostgroup_name "${_hostgroup_name}" )
$( [[ ! -z ${_last_notification} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" last_notification "${_last_notification}" )
$( [[ ! -z ${_notification_interval} ]] && ${cmd_printf} '%-1s %-32s %-50s' "" notification_interval "${_notification_interval}" )
$( [[ ! -z ${_service_description} ]]   && ${cmd_printf} '%-1s %-32s %-50s' "" service_description "${_service_description}" )
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